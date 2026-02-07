//
//  HistoryView.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/5/26.
//

import SwiftUI

struct HistoryView: View {
    @Binding var currentScreen: AppScreen
    @ObservedObject var audioManager: AudioManager

    var body: some View {
        ZStack {
            // Dark background
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                
                // Top bar
                HStack {
                    Button {
                        currentScreen = .home
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Text("History")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Placeholder for symmetry
                    Color.clear
                        .frame(width: 18, height: 18)
                }
                .padding(.horizontal)
                .padding(.vertical, 16)

                // Content
                if audioManager.recordings.isEmpty {
                    EmptyHistoryView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(audioManager.recordings) { recording in
                                RecordingRow(
                                    recording: recording,
                                    isPlaying: audioManager.currentlyPlayingID == recording.id,
                                    onPlay: { audioManager.togglePlayback(for: recording) },
                                    onViewFeedback: { currentScreen = .feedback(recording) },
                                    onDelete: { audioManager.deleteRecording(recording) }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .onDisappear {
            audioManager.stopPlayback()
        }
    }
}

// MARK: - Empty History View

struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "waveform")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(.white.opacity(0.3))
            }
            
            Text("No recordings yet")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            Text("Your practice sessions will appear here")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Recording Row

struct RecordingRow: View {
    let recording: Recording
    let isPlaying: Bool
    let onPlay: () -> Void
    let onViewFeedback: () -> Void
    let onDelete: () -> Void
    
    @State private var showDeleteConfirmation = false

    var body: some View {
        HStack(spacing: 14) {
            // Play/Stop button
            Button(action: onPlay) {
                ZStack {
                    Circle()
                        .fill(isPlaying ? Color.red.opacity(0.15) : Color.blue.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    // Animated ring when playing
                    if isPlaying {
                        Circle()
                            .stroke(Color.red.opacity(0.3), lineWidth: 2)
                            .frame(width: 50, height: 50)
                        
                        SpinningRing()
                            .frame(width: 50, height: 50)
                    }
                    
                    Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isPlaying ? .red : .blue)
                }
            }
            .buttonStyle(.plain)

            // Recording info
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(formatDate(recording.date))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if isPlaying {
                        PlayingIndicator()
                    }
                }

                HStack(spacing: 12) {
                    // Duration
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                        Text(formatDuration(recording.duration))
                            .font(.system(size: 13))
                    }
                    .foregroundColor(.white.opacity(0.5))
                    
                    // Pauses
                    HStack(spacing: 4) {
                        Image(systemName: "pause.circle")
                            .font(.system(size: 11))
                        Text("\(recording.pauses.count) pauses")
                            .font(.system(size: 13))
                    }
                    .foregroundColor(.white.opacity(0.5))
                }

                // Notes indicator
                if let notes = recording.notes, !notes.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 10))
                        Text("Has notes")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.white.opacity(0.4))
                }
            }

            Spacer()

            // Actions
            HStack(spacing: 8) {
                // Delete button
                Button {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
                // View feedback button
                Button(action: onViewFeedback) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isPlaying ? Color.red.opacity(0.3) : Color.white.opacity(0.08),
                            lineWidth: 1
                        )
                )
        )
        .confirmationDialog(
            "Delete Recording",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                withAnimation {
                    onDelete()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    // MARK: - Helpers
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today, " + date.formatted(date: .omitted, time: .shortened)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday, " + date.formatted(date: .omitted, time: .shortened)
        } else {
            return date.formatted(date: .abbreviated, time: .shortened)
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}

// MARK: - Spinning Ring Animation

struct SpinningRing: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.3)
            .stroke(Color.red, lineWidth: 2)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

// MARK: - Animated Playing Indicator (Sound Bars)

struct PlayingIndicator: View {
    @State private var animating = false
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .fill(Color.red)
                    .frame(width: 2, height: animating ? 10 : 4)
                    .animation(
                        .easeInOut(duration: 0.4)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.15),
                        value: animating
                    )
            }
        }
        .onAppear { animating = true }
    }
}

#Preview("History View") {
    let audioManager = AudioManager()

    let _ = {
        audioManager.recordings = [
            Recording(
                id: UUID(),
                url: URL(fileURLWithPath: "/dev/null"),
                date: Date(),
                duration: 125.2,
                speakingTime: 98.1,
                pauses: [0.5, 1.2, 0.8],
                notes: "My presentation notes"
            ),
            Recording(
                id: UUID(),
                url: URL(fileURLWithPath: "/dev/null"),
                date: Date().addingTimeInterval(-86400),
                duration: 32.5,
                speakingTime: 22.4,
                pauses: [0.8, 1.2],
                notes: nil
            ),
            Recording(
                id: UUID(),
                url: URL(fileURLWithPath: "/dev/null"),
                date: Date().addingTimeInterval(-172800),
                duration: 245.0,
                speakingTime: 180.5,
                pauses: [0.3, 0.5, 0.8, 1.1, 2.3],
                notes: "Interview practice"
            )
        ]
    }()

    HistoryView(
        currentScreen: .constant(.history),
        audioManager: audioManager
    )
}

#Preview("History View - Empty") {
    let audioManager = AudioManager()
    
    HistoryView(
        currentScreen: .constant(.history),
        audioManager: audioManager
    )
}
