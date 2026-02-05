//
//  HomeView.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/1/26.
//

import SwiftUI

struct HomeView: View {
    @Binding var currentScreen: AppScreen
    @State private var selectedMode: PracticeMode? = nil

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("What are you practicing?")
                .font(.system(size: 28, weight: .semibold))

            Text("Select a practice mode to continue.")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            // Practice modes
            VStack(spacing: 16) {

                PracticeCard(
                    title: "Interview",
                    subtitle: "Answer clearly and confidently",
                    isSelected: selectedMode == .interview
                ) {
                    selectedMode = .interview
                }

                PracticeCard(
                    title: "Presentation",
                    subtitle: "Practice pacing and emphasis",
                    isSelected: selectedMode == .presentation
                ) {
                    selectedMode = .presentation
                }

                PracticeCard(
                    title: "Storytelling",
                    subtitle: "Work on flow and engagement",
                    isSelected: selectedMode == .storytelling
                ) {
                    selectedMode = .storytelling
                }

                PracticeCard(
                    title: "Free Practice",
                    subtitle: "Just speak and reflect",
                    isSelected: selectedMode == .free
                ) {
                    selectedMode = .free
                }
            }

            // Start button
            Button("Start Practice") {
                guard let mode = selectedMode else { return }

                if mode.requiresNotes {
                    currentScreen = .notes(mode)
                } else {
                    currentScreen = .grounding(mode)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(selectedMode == nil)
            .opacity(selectedMode == nil ? 0.5 : 1)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    HomeView(currentScreen: .constant(.home))
}
