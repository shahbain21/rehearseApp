import SwiftUI

struct ContentView: View {
    @State private var screen: AppScreen = .home
    @StateObject private var audioManager = AudioManager()

    var body: some View {
        switch screen {
        case .home:
            HomeView(currentScreen: $screen)

        case .notes(let mode):
            NotesView(currentScreen: $screen, mode: mode)

        case .grounding(let mode):
            GroundingView(currentScreen: $screen, mode: mode)

        case .recording(let mode):
            RecordingView(
                currentScreen: $screen,
                audioManager: audioManager,
                mode: mode
            )

        case .feedback(let recording):
            FeedbackView(
                currentScreen: $screen,
                recording: recording
            )

        case .history:
            HistoryView(
                currentScreen: $screen,
                audioManager: audioManager
            )

        case .reflection:
            ReflectionView(currentScreen: $screen)
        }
    }
}
