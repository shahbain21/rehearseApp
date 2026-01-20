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
        List(audioManager.recordings) { recording in
            VStack(alignment: .leading) {
                Text(recording.date.formatted())
                    .font(.headline)

                Text("Duration: \(recording.duration, specifier: "%.1f")s")
                Text("Speaking: \(recording.speakingTime, specifier: "%.1f")s")
                Text("Pauses: \(recording.pauses.count)")
            }
        }
        
        Button("Recording") {
            withAnimation {
                currentScreen = .recording
            }
        }
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
