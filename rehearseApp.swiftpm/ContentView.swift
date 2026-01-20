import SwiftUI

struct ContentView: View {
    @State private var screen: AppScreen = .home
    @StateObject private var audioManager = AudioManager()

    var body: some View {
        switch screen {
        case .home:
            HomeView(currentScreen: $screen)

        case .grounding:
            GroundingView(currentScreen: $screen)

        case .recording:
            RecordingView(
                currentScreen: $screen,
                audioManager: audioManager
            )

        case .feedback:
            let recording = audioManager.recordings.first!
            FeedbackView(
                currentScreen: $screen,
                recording: recording
            )

        case .reflection:
            ReflectionView(currentScreen: $screen)

        case .history:
            HistoryView(
                currentScreen: $screen,
                audioManager: audioManager
            )
        }
    }
}
