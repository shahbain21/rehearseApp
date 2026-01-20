//
//  HomeView.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/1/26.
//

import SwiftUI

struct HomeView: View {
    @Binding var currentScreen: AppScreen
    @State private var selectedMode: PracticeMode = .warmUp

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("What are you practicing?")
                .font(.system(size: 28, weight: .semibold))

            Text("Choose a practice mode.\nEach focuses on a different speaking style.")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 16) {

                PracticeCard(
                    title: "Interview",
                    subtitle: "Answer clearly and confidently",
                    isSelected: selectedMode == .warmUp
                ) {
                    selectedMode = .warmUp
                }

                PracticeCard(
                    title: "Presentation",
                    subtitle: "Practice pacing and emphasis",
                    isSelected: selectedMode == .clarity
                ) {
                    selectedMode = .clarity
                }

                PracticeCard(
                    title: "Storytelling",
                    subtitle: "Work on flow and engagement",
                    isSelected: selectedMode == .structure
                ) {
                    selectedMode = .structure
                }

                PracticeCard(
                    title: "Free Practice",
                    subtitle: "Just speak and reflect",
                    isSelected: false
                ) {
                    // For now, map to any existing mode
                    selectedMode = .warmUp
                }
            }

            Button("Start Practice") {
                currentScreen = .grounding
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    HomeView(currentScreen: .constant(.home))
}
