//
//  SpeechAnalyzer.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 2/23/26.
//

@preconcurrency import Speech
import AVFoundation
import Foundation

// List of possible errors that can occur
enum SpeechAnalysisError: LocalizedError {
    case notAuthorized
    case recognizerUnavailable
    case audioTooLong(TimeInterval)
    case timedOut
    case noResult
    case failed(Error)

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Speech recognition permission denied"
        case .recognizerUnavailable:
            return "Speech recognizer not available"
        case .audioTooLong(let duration):
            return "Audio too long (\(Int(duration))s). Max is 4 minutes."
        case .timedOut:
            return "Speech recognition timed out"
        case .noResult:
            return "No speech detected in recording"
        case .failed(let error):
            return "Recognition failed: \(error.localizedDescription)"
        }
    }
}

final class SpeechAnalyzer {
    
    private static let maxDuration: TimeInterval = 240
    private static let timeout: TimeInterval = 30
    
    // Transcribes an audio file at the given URL.
    static func transcribe(url: URL) async throws -> TranscriptResult {
        
        // Check authorization
        try await ensureAuthorized()
        
        // Validate file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw SpeechAnalysisError.failed(
                NSError(domain: "SpeechAnalyzer", code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Audio file not found"])
            )
        }
        
        // Check if duration is too long
        let duration: TimeInterval
        do {
            duration = try await audioDuration(for: url)
        } catch {
            duration = 120
        }
        
        guard duration <= maxDuration else {
            throw SpeechAnalysisError.audioTooLong(duration)
        }
        
        // Check if it is in English
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US")),
              recognizer.isAvailable else {
            throw SpeechAnalysisError.recognizerUnavailable
        }
        
        // Transcribe
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false
        request.taskHint = .dictation
        
        // Kill if it takes too long
        let transcript = try await withTimeout(seconds: timeout + duration) {
            try await Self.recognizeAndParse(with: recognizer, request: request)
        }
        
        return transcript
    }

    // Check to see if its authorized, return error if not
    private static func ensureAuthorized() async throws {
        let status = SFSpeechRecognizer.authorizationStatus()
        
        switch status {
        case .authorized:
            return
        case .notDetermined:
            let granted = await withCheckedContinuation { continuation in
                SFSpeechRecognizer.requestAuthorization { newStatus in
                    continuation.resume(returning: newStatus == .authorized)
                }
            }
            guard granted else {
                throw SpeechAnalysisError.notAuthorized
            }
        case .denied, .restricted:
            throw SpeechAnalysisError.notAuthorized
        @unknown default:
            throw SpeechAnalysisError.notAuthorized
        }
    }

    // Reads the duration in seconds
    private static func audioDuration(for url: URL) async throws -> TimeInterval {
        let asset = AVURLAsset(url: url)
        let cmDuration = try await asset.load(.duration)
        return CMTimeGetSeconds(cmDuration)
    }

    // Process the audio
    private static func recognizeAndParse(
        with recognizer: SFSpeechRecognizer,
        request: SFSpeechURLRecognitionRequest
    ) async throws -> TranscriptResult {

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<TranscriptResult, Error>) in

            let lock = NSLock()
            var hasResumed = false
            
            // Prevents app from crashing from calling resume twice
            func resumeOnce(with result: Result<TranscriptResult, Error>) {
                lock.lock()
                defer { lock.unlock() }
                guard !hasResumed else { return }
                hasResumed = true
                continuation.resume(with: result)
            }

            // Parses the audio
            let task = recognizer.recognitionTask(with: request) { result, error in
                if let error {
                    resumeOnce(with: .failure(SpeechAnalysisError.failed(error)))
                    return
                }

                if let result, result.isFinal {
                    let transcript = Self.parseResult(result)
                    resumeOnce(with: .success(transcript))
                }
            }

            // In case it never calls back, we end it
            Task {
                try? await Task.sleep(nanoseconds: UInt64(60 * 1_000_000_000))
                resumeOnce(with: .failure(SpeechAnalysisError.timedOut))
                task.cancel()
            }
        }
    }

    // Gives recognition a timer to complete task
    private static func withTimeout<T: Sendable>(
        seconds: TimeInterval,
        operation: @escaping @Sendable () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }

            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw SpeechAnalysisError.timedOut
            }

            guard let result = try await group.next() else {
                throw SpeechAnalysisError.noResult
            }
            group.cancelAll()
            return result
        }
    }

    // Parses the result into TranscriptResult
    private static func parseResult(_ result: SFSpeechRecognitionResult) -> TranscriptResult {
        let transcription = result.bestTranscription

        let words = transcription.segments.map { segment in
            TranscriptWord(
                text: segment.substring,
                timestamp: segment.timestamp,
                duration: segment.duration,
                confidence: segment.confidence
            )
        }

        let lastSegment = transcription.segments.last
        let totalDuration = (lastSegment?.timestamp ?? 0) + (lastSegment?.duration ?? 0)

        guard !words.isEmpty else {
            return TranscriptResult(
                fullText: "",
                words: [],
                duration: totalDuration
            )
        }

        return TranscriptResult(
            fullText: transcription.formattedString,
            words: words,
            duration: totalDuration
        )
    }
}
