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
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 24) {
                
                // Top bar
                HStack {
                    Text("Rehearse")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        currentScreen = .history
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                Spacer()

                // Header
                VStack(spacing: 12) {
                    Text("What are you practicing?")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)

                    Text("Select a practice mode to continue.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }

                // Practice modes
                VStack(spacing: 12) {
                    ForEach([PracticeMode.interview, .presentation, .storytelling, .free], id: \.self) { mode in
                        PracticeCard(
                            icon: mode.icon,
                            title: mode.displayName,
                            subtitle: mode.subtitle,
                            isSelected: selectedMode == mode
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedMode = mode
                            }
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Action buttons
                VStack(spacing: 12) {
                    // Start with notes
                    Button {
                        guard let mode = selectedMode else { return }
                        currentScreen = .notes(mode)
                    } label: {
                        HStack {
                            Image(systemName: "doc.text")
                            Text("Start with Notes")
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(selectedMode == nil ? .white.opacity(0.3) : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(selectedMode == nil
                                    ? Color.white.opacity(0.1)
                                    : Color.blue)
                        )
                    }
                    .disabled(selectedMode == nil)
                    
                    // Quick start (no notes)
                    Button {
                        guard let mode = selectedMode else { return }
                        NotesStore.shared.currentNotes = nil
                        currentScreen = .grounding(mode)
                    } label: {
                        Text("Quick Start")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(selectedMode == nil ? .white.opacity(0.2) : .white.opacity(0.6))
                    }
                    .disabled(selectedMode == nil)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    HomeView(currentScreen: .constant(.home))
}
