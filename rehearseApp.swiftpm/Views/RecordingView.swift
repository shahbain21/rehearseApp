//
//  RecordingView.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/1/26.
//

import SwiftUI

struct RecordingView: View {

    @Binding var currentScreen: AppScreen
    @ObservedObject var audioManager: AudioManager
    let mode: PracticeMode

    var body: some View {
        VStack(spacing: 20) {

            Spacer()

            // Mode context
            Text(modeTitle)
                .font(.system(size: 14))
                .foregroundColor(.secondary)

            // Gentle guidance
            Text("Speak naturally. Pauses are welcome.")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            // Notes overlay (if any)
            if let notes = NotesStore.shared.currentNotes, !notes.isEmpty {
                ScrollView {
                    Text(notes)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .padding()
                }
                .frame(maxHeight: 120)
                .background(Color.gray.opacity(0.08))
                .cornerRadius(12)
            }

            // Timer
            Text(formatTime(audioManager.elapsedTime))
                .font(.system(size: 36, weight: .medium))
                .padding(.vertical, 12)

            Spacer()

            // Record / Stop Button
            Button {
                toggleRecording()
            } label: {
                Text(audioManager.isRecording ? "Stop" : "Record")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 88, height: 88)
                    .background(audioManager.isRecording ? Color.red : Color.blue)
                    .clipShape(Circle())
            }

            // History shortcut
            Button("View History") {
                withAnimation {
                    currentScreen = .history
                }
            }
            .font(.system(size: 14))
            .foregroundColor(.blue)

            // Safety copy
            if audioManager.isRecording {
                Text("You can stop anytime.")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - Helpers

    private var modeTitle: String {
        switch mode {
        case .interview:
            return "Interview Practice"
        case .presentation:
            return "Presentation Practice"
        case .storytelling:
            return "Storytelling Practice"
        case .free:
            return "Free Practice"
        }
    }

    private func toggleRecording() {
        if audioManager.isRecording {
            audioManager.stopRecording()

            // Navigate to feedback for the latest recording
            if let latest = audioManager.recordings.first {
                withAnimation {
                    currentScreen = .feedback(latest)
                }
            }
        } else {
            audioManager.startRecording()
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview("Recording View") {
    let audioManager = AudioManager()

    let _ = {
        audioManager.isRecording = false
    }()

    RecordingView(
        currentScreen: .constant(.recording(.presentation)),
        audioManager: audioManager,
        mode: .presentation
    )
}
