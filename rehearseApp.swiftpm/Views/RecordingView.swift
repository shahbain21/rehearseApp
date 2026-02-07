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

    @State private var currentSlideIndex = 0
    @State private var showNotes = false

    var body: some View {
        ZStack {
            // Dark background
            Color(red: 0.08, green: 0.08, blue: 0.14)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                
                // Top bar with mode and notes toggle
                HStack {
                    Button {
                        if audioManager.isRecording {
                            audioManager.stopRecording()
                        }
                        withAnimation {
                            currentScreen = .home
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Text(modeTitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    if !noteSlides.isEmpty {
                        Button {
                            withAnimation {
                                showNotes.toggle()
                            }
                        } label: {
                            Image(systemName: showNotes ? "doc.text.fill" : "doc.text")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    } else {
                        Color.clear
                            .frame(width: 18, height: 18)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                Spacer()
                
                // Notes overlay (collapsible)
                if showNotes && !noteSlides.isEmpty {
                    VStack(spacing: 12) {
                        Text(noteSlides[currentSlideIndex])
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)

                        HStack {
                            Button {
                                currentSlideIndex = max(currentSlideIndex - 1, 0)
                            } label: {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.white.opacity(currentSlideIndex == 0 ? 0.3 : 0.7))
                            }
                            .disabled(currentSlideIndex == 0)

                            Spacer()

                            Text("\(currentSlideIndex + 1) / \(noteSlides.count)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))

                            Spacer()

                            Button {
                                currentSlideIndex = min(currentSlideIndex + 1, noteSlides.count - 1)
                            } label: {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(currentSlideIndex == noteSlides.count - 1 ? 0.3 : 0.7))
                            }
                            .disabled(currentSlideIndex == noteSlides.count - 1)
                        }
                        .font(.system(size: 16))
                    }
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Spacer()

                // Waveform visualization
                MirroredWaveformView(
                    audioLevel: audioManager.currentAudioLevel,
                    barCount: 60,
                    isRecording: audioManager.isRecording
                )
                .frame(height: 120)
                .padding(.horizontal)

                Spacer()

                // Timer
                Text(formatTime(audioManager.elapsedTime))
                    .font(.system(size: 64, weight: .light, design: .rounded))
                    .foregroundColor(.white)
                    .monospacedDigit()

                // Status text
                Text(statusText)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))

                Spacer()

                // Controls
                HStack(spacing: 60) {
                    // History button
                    Button {
                        withAnimation {
                            currentScreen = .history
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 22))
                            Text("History")
                                .font(.system(size: 11))
                        }
                        .foregroundColor(.white.opacity(0.6))
                    }

                    // Record / Stop Button
                    Button {
                        toggleRecording()
                    } label: {
                        ZStack {
                            // Outer ring
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 4)
                                .frame(width: 80, height: 80)
                            
                            // Inner circle/square
                            if audioManager.isRecording {
                                // Stop button (rounded square)
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.red)
                                    .frame(width: 32, height: 32)
                            } else {
                                // Record button (circle)
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 64, height: 64)
                            }
                        }
                    }
                    
                    // Placeholder for symmetry (or add another button)
                    VStack(spacing: 6) {
                        Image(systemName: "gear")
                            .font(.system(size: 22))
                        Text("Settings")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.white.opacity(0.6))
                    .opacity(0.5)
                }
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Computed Properties

    private var noteSlides: [String] {
        guard let notes = NotesStore.shared.currentNotes else { return [] }

        return notes
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

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
    
    private var statusText: String {
        if audioManager.isRecording {
            return "Recording..."
        } else if audioManager.elapsedTime > 0 {
            return "Paused"
        } else {
            return "Tap to record"
        }
    }

    // MARK: - Actions

    private func toggleRecording() {
        if audioManager.isRecording {
            audioManager.stopRecording()

            if let latest = audioManager.recordings.first {
                withAnimation {
                    currentScreen = .feedback(latest)
                }
            }
        } else {
            currentSlideIndex = 0
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
        NotesStore.shared.currentNotes = """
        Introduction
        Problem statement
        Key solution
        Demo walkthrough
        Conclusion
        """
    }()

    RecordingView(
        currentScreen: .constant(.recording(.presentation)),
        audioManager: audioManager,
        mode: .presentation
    )
}

#Preview("Recording - Active") {
    let audioManager = AudioManager()
    
    RecordingView(
        currentScreen: .constant(.recording(.free)),
        audioManager: audioManager,
        mode: .free
    )
}
