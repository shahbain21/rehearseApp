import AVFoundation
import Foundation

/*
 AudioManager records audio and estimates speaking behavior.

 Every `meterInterval` seconds:
 - Measure microphone loudness (in dB)
 - If loudness > speechThreshold → user is speaking
 - Otherwise → silence

 From this we derive:
 - Total recording duration
 - Total speaking time
 - Durations of pauses between speaking segments
*/

@MainActor
final class AudioManager: NSObject, ObservableObject {


    @Published var isRecording = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var speakingTime: TimeInterval = 0
    @Published var pauses: [TimeInterval] = []
    @Published var recordings: [Recording] = []
    @Published var currentlyPlayingID: UUID?
    @Published var isPlaying = false
    @Published var currentAudioLevel: Float = 0.0
    @Published var volumeSamples: [Float] = []
    private var meterUpdateCount: Int = 0


    // Recording Lifecycle State

    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var meterTimer: Timer?
    private var recordingStartTime: Date?
    private var currentRecordingURL: URL?
    private var silenceStartTime: Date?
    
    private lazy var playerDelegateHandler: AudioPlayerDelegateHandler = {
            let handler = AudioPlayerDelegateHandler()
            handler.audioManager = self
            return handler
        }()

    private var recordingsFileURL: URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("recordings.json")
    }


    // Speech Detection State

    // Whether the user is currently speaking or silent
    private enum SpeechState {
        case speaking
        case silent
    }

    private var speechState: SpeechState = .silent


    // Configuration

    // Loudness above this value is treated as speech (in dB)
    private let speechThreshold: Float = -55.0
    
    // How often we sample microphone levels
    private let meterInterval: TimeInterval = 0.1


    // Loads recording when audio manager is initialized
    override init() {
        super.init()
        loadRecordings()
    }
    
    // Loads the recordings from documents into array
    private func loadRecordings() {
        do {
            let data = try Data(contentsOf: recordingsFileURL)
            recordings = try JSONDecoder().decode([Recording].self, from: data)
        } catch {
            recordings = []
        }
    }
    
    // Encodes recordings into JSON and writes to disk
    private func persistRecordings() {
        do {
            let data = try JSONEncoder().encode(recordings)
            try data.write(to: recordingsFileURL)
        } catch {
            print("Failed to save recordings:", error)
        }
    }
    
    // Recording Life Cycle
    
    // Asks permission than starts recording
    func startRecording() {
        requestMicrophonePermission { granted in
            guard granted else {
                print("Microphone permission denied")
                return
            }

            do {
                try self.beginRecordingSession()
            } catch {
                print("Recording failed:", error)
            }
        }
    }

    private func beginRecordingSession() throws {
        try configureAudioSession()

        let url = makeRecordingURL()
        currentRecordingURL = url

        audioRecorder = try AVAudioRecorder(
            url: url,
            settings: recorderSettings
        )
        audioRecorder?.isMeteringEnabled = true
        audioRecorder?.record()

        resetMetrics()
        startMetering()

        isRecording = true
    }
    
    // Ends recording and saves it
    func stopRecording(mode: PracticeMode) {
        finalizeLastPauseIfNeeded()
        endRecordingSession()
        saveRecording(mode: mode)
    }

    // Saves recording and adds it to array
    func saveRecording(mode: PracticeMode) {
        guard let url = currentRecordingURL else { return }

        let recording = Recording(
            id: UUID(),
            url: url,
            date: Date(),
            duration: elapsedTime,
            speakingTime: speakingTime,
            pauses: pauses,
            notes: NotesStore.shared.currentNotes,
            volumeSamples: volumeSamples.isEmpty ? nil : volumeSamples,
            mode: mode 
        )

        recordings.insert(recording, at: 0)
        persistRecordings()
        NotesStore.shared.currentNotes = nil
    }

    // Stops recording without saving
    func discardRecording() {
        finalizeLastPauseIfNeeded()
        audioRecorder?.stop()
        audioRecorder = nil
        stopMetering()
        isRecording = false
        
        // Delete the audio file from disk since we're discarding
        if let url = currentRecordingURL {
            try? FileManager.default.removeItem(at: url)
        }
        
        // Clear the current recording data
        currentRecordingURL = nil
        NotesStore.shared.currentNotes = nil
        resetMetrics()

    }
    
    // Deletes Recording from array and disk
    func deleteRecording(_ recording: Recording) {
        try? FileManager.default.removeItem(at: recording.url)
        recordings.removeAll { $0.id == recording.id }
        persistRecordings()
    }

    // Stops recording and notifies UI
    private func endRecordingSession() {
        audioRecorder?.stop()
        audioRecorder = nil
        stopMetering()
        isRecording = false
    }
    
    // Saves reflection to existing recording
    func saveReflection(_ reflection: Reflection, for recording: Recording) {
        if let index = recordings.firstIndex(where: { $0.id == recording.id }) {
            recordings[index].reflection = reflection
            persistRecordings()
        }
    }
    
    // Metering & Speech Analysis

    // Timer that calls updateMeter every 0.1 seconds
    private func startMetering() {
        meterTimer = Timer.scheduledTimer(
            withTimeInterval: meterInterval,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                self?.updateMeters()
            }
        }
    }

    // Stops timer
    private func stopMetering() {
        meterTimer?.invalidate()
        meterTimer = nil
    }

    // Gets statistics from recorder
    private func updateMeters() {
        guard let recorder = audioRecorder else { return }
        recorder.updateMeters()
        
        // Raw data
        let power = recorder.averagePower(forChannel: 0)
        let now = Date()

        // Cleaned up Data
        currentAudioLevel = normalizedPowerLevel(from: power) // Loudness
        elapsedTime = now.timeIntervalSince(recordingStartTime ?? now)

        handleSpeechState(for: power, at: now)
        
        trackVolumeSample(power)
    }

    // Normalizes dB level to range from 0(silent) to 1(max)
    private func normalizedPowerLevel(from decibels: Float) -> Float {
        let minDb: Float = -60.0
        let maxDb: Float = 0.0
        
        let clamped = max(minDb, min(decibels, maxDb))
        return (clamped - minDb) / (maxDb - minDb)
    }
    
    // Handles changes in speech state
    private func handleSpeechState(for power: Float, at time: Date) {
        let isSpeaking = power > speechThreshold

        switch (speechState, isSpeaking) {
        // silence → speaking, store pause
        case (.silent, true):
            if let silenceStartTime {
                pauses.append(time.timeIntervalSince(silenceStartTime))
            }
            speechState = .speaking
            silenceStartTime = nil
        // speaking → speaking, update speaking time
        case (.speaking, true):
            speakingTime += meterInterval

        // speaking → silence, measure pause time
        case (.speaking, false):
            speechState = .silent
            silenceStartTime = time

        // silence → silence
        case (.silent, false):
            break
        }
    }
    
    // Tracks volume samples
    private func trackVolumeSample(_ power: Float) {
        meterUpdateCount += 1
        if meterUpdateCount % 5 == 0 {
            volumeSamples.append(power)
        }
    }
    
    // Catches any final pauses
    private func finalizeLastPauseIfNeeded() {
        guard
            speechState == .silent,
            let silenceStartTime
        else { return }

        let pauseDuration = Date().timeIntervalSince(silenceStartTime)
        pauses.append(pauseDuration)
    }

    // Metrics Reset & Persistence

    private func resetMetrics() {
        recordingStartTime = Date()
        silenceStartTime = recordingStartTime
        elapsedTime = 0
        speakingTime = 0
        pauses.removeAll()
        speechState = .silent
        volumeSamples = []
        meterUpdateCount = 0
    }

    func updateTranscript(_ transcript: TranscriptResult, for recording: Recording) {
        if let index = recordings.firstIndex(where: { $0.id == recording.id }) {
            recordings[index].transcript = transcript
            persistRecordings()
        }
    }
    
    // Playing Audio

    // Plays the audio
    func play(_ recording: Recording) {
          // Stop any current playback first
          stopPlayback()
          // Checks to see if files exists
          guard FileManager.default.fileExists(atPath: recording.url.path) else {
              print("Recording file not found at:", recording.url.path)
              return
          }
          do {
              let session = AVAudioSession.sharedInstance()
              try session.setCategory(.playback, mode: .default)
              try session.setActive(true)
              
              audioPlayer = try AVAudioPlayer(contentsOf: recording.url)
              audioPlayer?.delegate = playerDelegateHandler
              audioPlayer?.prepareToPlay()
              audioPlayer?.play()
              
              currentlyPlayingID = recording.id
              isPlaying = true
          } catch {
              print("Playback failed:", error)
          }
      }

    // Stops playback and resets state
    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        currentlyPlayingID = nil
        isPlaying = false
    }

    // Used for the play/pause button
    func togglePlayback(for recording: Recording) {
        if currentlyPlayingID == recording.id, isPlaying {
            stopPlayback()
        } else {
            play(recording)
        }
    }
    
    //
    func playbackDidFinish() {
            currentlyPlayingID = nil
            isPlaying = false
        }
        
    
    //  Helpers

    // Defines the audio recording format
    private var recorderSettings: [String: Any] {
        [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
    }

    // Requests Mic permission asynchrously
    private func requestMicrophonePermission(
        completion: @escaping (Bool) -> Void
    ) {
        AVAudioSession.sharedInstance()
            .requestRecordPermission { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
    }
    
    // Configures hardware settings for audio
    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(
            .playAndRecord,
            mode: .spokenAudio,
            options: [
                .defaultToSpeaker,
                .allowBluetoothHFP
            ]
        )
        try session.setActive(true)
    }
    
    // Unique file in the documents path
    private func makeRecordingURL() -> URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(UUID().uuidString + ".m4a")
    }
    
    // Derived Presentation Metrics

    // Time spent speaking
    var speakingRatio: Double {
        guard elapsedTime > 0 else { return 0 }
        return speakingTime / elapsedTime
    }

    var averagePauseDuration: TimeInterval {
        guard !pauses.isEmpty else { return 0 }
        return pauses.reduce(0, +) / Double(pauses.count)
    }

    // Tracks moments of hesitations
    var longPauseCount: Int {
        pauses.filter { $0 > 2.0 }.count
    }

    
    var averageSpeakingSegmentLength: TimeInterval {
        speakingTime / Double(speakingSegmentCount)
    }
    
    var speakingSegmentCount: Int {
        max(pauses.count - 1, 1)
    }
}

// Alert for when the audio is done playing. 
private class AudioPlayerDelegateHandler: NSObject, AVAudioPlayerDelegate {
    weak var audioManager: AudioManager?
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor [weak audioManager] in
            audioManager?.playbackDidFinish()
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio decode error:", error?.localizedDescription ?? "unknown")
        Task { @MainActor [weak audioManager] in
            audioManager?.playbackDidFinish()
        }
    }
}
