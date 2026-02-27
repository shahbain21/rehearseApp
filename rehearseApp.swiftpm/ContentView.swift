import SwiftUI

struct ContentView: View {
    @State private var screen: AppScreen = .home
    @StateObject private var audioManager = AudioManager()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            switch screen {
            case .home:
                HomeView(currentScreen: $screen,
                         audioManager: audioManager)

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
                    recording: recording,
                    audioManager: audioManager
                )

            case .history:
                HistoryView(
                    currentScreen: $screen,
                    audioManager: audioManager
                )

            case .reflection(let recording):
                ReflectionView(
                    currentScreen: $screen,
                    recording: recording,
                    audioManager: audioManager
                )

            case .onboarding:
                OnboardingView(currentScreen: $screen)
            }
        }
        .onAppear {
            if !hasCompletedOnboarding {
                screen = .onboarding
            }
        }
    }
}
