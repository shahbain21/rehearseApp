//
//  HomeView.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/1/26.
//

import SwiftUI

struct HomeView: View {
    @Binding var currentScreen: AppScreen
    @State private var selectedMode: PracticeMode = .free


    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("What are you practicing?")
                .font(.system(size: 28, weight: .semibold))

            Text("Choose a practice mode.\nEach focuses on a different speaking style.")
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
                           if selectedMode.requiresNotes {
                               currentScreen = .notes(selectedMode)
                           } else {
                               currentScreen = .grounding(selectedMode)
                           }
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
