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
        List {
            ForEach(audioManager.recordings) { recording in
                HStack(spacing: 12) {

                    // ▶️ Play button
                    Button {
                        audioManager.play(recording)
                    } label: {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 28))
                    }
                    .buttonStyle(.plain)

                    // Recording info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(recording.date.formatted())
                            .font(.headline)

                        Text("Duration: \(recording.duration, specifier: "%.1f")s")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("Pauses: \(recording.pauses.count)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        if let notes = recording.notes, !notes.isEmpty {
                            Text("Has notes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Spacer()

                    // ➤ View feedback
                    Button {
                        currentScreen = .feedback(recording)
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 8)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        audioManager.deleteRecording(recording)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle("History")
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
                duration: 16.2,
                speakingTime: 16.1,
                pauses: [0.1],
                notes: nil
            ),
            Recording(
                id: UUID(),
                url: URL(fileURLWithPath: "/dev/null"),
                date: Date().addingTimeInterval(-3600),
                duration: 32.5,
                speakingTime: 22.4,
                pauses: [0.8, 1.2],
                notes: nil
            )
        ]
    }()

    HistoryView(
        currentScreen: .constant(.history),
        audioManager: audioManager
    )
}
