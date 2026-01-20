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

    // MARK: - Public State (Observed by UI)

    @Published var isRecording = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var speakingTime: TimeInterval = 0
    @Published var pauses: [TimeInterval] = []
    @Published var recordings: [Recording] = []

    // MARK: - Recording Lifecycle State

    private var audioRecorder: AVAudioRecorder?
    private var meterTimer: Timer?
    private var recordingStartTime: Date?
    private var currentRecordingURL: URL?
    private var silenceStartTime: Date?
    var speakingSegmentCount: Int {
        max(pauses.count - 1, 1)
    }
    private var recordingsFileURL: URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("recordings.json")
    }


    // MARK: - Speech Detection State

    /// Whether the user is currently speaking or silent
    private enum SpeechState {
        case speaking
        case silent
    }

    private var speechState: SpeechState = .silent

    /// Time when the speech state last changed
    //private var lastSpeechStateChange = Date()

    // MARK: - Configuration

    /// Loudness above this value is treated as speech (in dB)
    private let speechThreshold: Float = -55.0
    
    /// How often we sample microphone levels
    private let meterInterval: TimeInterval = 0.1

    // MARK: - Public API (Recording Lifecycle)

    override init() {
        super.init()
        loadRecordings()
    }
    
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
    
    private func loadRecordings() {
        do {
            let data = try Data(contentsOf: recordingsFileURL)
            recordings = try JSONDecoder().decode([Recording].self, from: data)
        } catch {
            recordings = []
        }
    }

    func stopRecording() {
        finalizeLastPauseIfNeeded()   // ✅ MISSING
        endRecordingSession()
        saveRecording()
    }
    // MARK: - Recording Session Setup

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

    private func endRecordingSession() {
        audioRecorder?.stop()
        audioRecorder = nil
        stopMetering()
        isRecording = false
    }

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

    // MARK: - Metering & Speech Analysis

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

    private func stopMetering() {
        meterTimer?.invalidate()
        meterTimer = nil
    }

    private func updateMeters() {
        guard let recorder = audioRecorder else { return }

        recorder.updateMeters()

        let power = recorder.averagePower(forChannel: 0)
        let now = Date()

        // Total time since recording started
        elapsedTime = now.timeIntervalSince(recordingStartTime ?? now)

        handleSpeechState(for: power, at: now)
    }

    private func handleSpeechState(for power: Float, at time: Date) {
        let isSpeaking = power > speechThreshold

        switch (speechState, isSpeaking) {

        // silence → speaking
        case (.silent, true):
            if let silenceStartTime {
                pauses.append(time.timeIntervalSince(silenceStartTime))
            }
            speechState = .speaking
            silenceStartTime = nil

        // speaking → speaking
        case (.speaking, true):
            speakingTime += meterInterval

        // speaking → silence
        case (.speaking, false):
            speechState = .silent
            silenceStartTime = time

        // silence → silence
        case (.silent, false):
            break
        }
    }

    // MARK: - Metrics Reset & Persistence

    private func resetMetrics() {
        recordingStartTime = Date()
        silenceStartTime = recordingStartTime

        elapsedTime = 0
        speakingTime = 0
        pauses.removeAll()

        speechState = .silent
    }

    private func saveRecording() {
        guard let url = currentRecordingURL else { return }

        let recording = Recording(
            id: UUID(),
            url: url,
            date: Date(),
            duration: elapsedTime,
            speakingTime: speakingTime,
            pauses: pauses,
            notes: NotesStore.shared.currentNotes   // ✅ attach notes
        )

        recordings.insert(recording, at: 0)
        persistRecordings()

        NotesStore.shared.currentNotes = nil // ✅ clear
    }

    func deleteRecording(_ recording: Recording) {
        // Remove audio file
        try? FileManager.default.removeItem(at: recording.url)

        // Remove metadata
        recordings.removeAll { $0.id == recording.id }

        // Persist change
        persistRecordings()
    }
    
    private func persistRecordings() {
        do {
            let data = try JSONEncoder().encode(recordings)
            try data.write(to: recordingsFileURL)
        } catch {
            print("Failed to save recordings:", error)
        }
    }
    // MARK: - Helpers

    private func makeRecordingURL() -> URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(UUID().uuidString + ".m4a")
    }

    private var recorderSettings: [String: Any] {
        [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
    }

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
    
    private func finalizeLastPauseIfNeeded() {
        guard
            speechState == .silent,
            let silenceStartTime
        else { return }

        let pauseDuration = Date().timeIntervalSince(silenceStartTime)
        pauses.append(pauseDuration)
    }
    
    // MARK: - Derived Presentation Metrics

    /// 1️⃣ Speaking ratio (confidence proxy)
    var speakingRatio: Double {
        guard elapsedTime > 0 else { return 0 }
        return speakingTime / elapsedTime
    }

    /// 2️⃣ Average pause duration
    var averagePauseDuration: TimeInterval {
        guard !pauses.isEmpty else { return 0 }
        return pauses.reduce(0, +) / Double(pauses.count)
    }

    /// 3️⃣ Long pause count (> 2 seconds)
    var longPauseCount: Int {
        pauses.filter { $0 > 2.0 }.count
    }

    /// 4️⃣ Average speaking segment length
    ///
    /// Estimated by dividing total speaking time by
    /// number of speaking segments (pauses).
    var averageSpeakingSegmentLength: TimeInterval {
        speakingTime / Double(speakingSegmentCount)
    }
}
