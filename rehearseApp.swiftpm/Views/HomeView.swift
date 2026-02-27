//
//  HomeView.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/1/26.
//

import SwiftUI

struct HomeView: View {
    @Binding var currentScreen: AppScreen
    @ObservedObject var audioManager: AudioManager
    @State private var selectedMode: PracticeMode? = nil
    @State private var appeared = false
    private var canStart: Bool {
        selectedMode != nil
    }
    

    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                topBar
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    Text("Select your practice mode")
                        .font(AppTheme.Fonts.screenTitle)
                        .foregroundColor(AppTheme.primaryText)
                }
                .padding(.horizontal, AppTheme.Spacing.xxl)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        modeList
                    }
                    .padding(.bottom, AppTheme.Spacing.lg)
                    .padding(.top, AppTheme.Spacing.xl)
                }
                actionButtons
            }
        }
        .onAppear {
            withAnimation {
                appeared = true
            }

        }
    }
    
    // Top Bar
    private var topBar: some View {
        HStack {
            Spacer()
            Button {
                currentScreen = .history
            } label: {
                Image(systemName: "clock.arrow.circlepath")
                    .font(AppTheme.Fonts.iconFont)
                    .foregroundColor(AppTheme.secondaryText)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("View practice history")
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.sm)
        .padding(.bottom, AppTheme.Spacing.sm)
    }
    
    // Mode List
    private var modeList: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // List of each mode
            ForEach(Array(PracticeMode.allCases.enumerated()), id: \.element) { index, mode in
                PracticeCard(
                    icon: mode.icon,
                    title: mode.displayName,
                    subtitle: mode.subtitle,
                    isSelected: selectedMode == mode,
                    accentColor: AppTheme.modeColor(for: mode)
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedMode = mode
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                // Animated Entrance of modes
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(
                    .easeOut(duration: 0.4).delay(Double(index) * 0.08),
                    value: appeared
                )
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
        }
    }
    
    // Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Button {
                guard let mode = selectedMode else { return }
                currentScreen = .notes(mode)
            } label: {
                HStack {
                    Image(systemName: "doc.text")
                    Text("Start with Notes")
                }
                .font(AppTheme.Fonts.buttonLabel)
                .foregroundColor(canStart ? AppTheme.primaryText : AppTheme.mutedText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.button)
                        .fill(canStart ? AppTheme.accent : AppTheme.cardBackground)
                )
            }
            // Needs to select mode to advance
            .disabled(!canStart)
            .accessibilityHint(canStart
                               ? "Opens the notes editor before your session"
                               : "Select a practice mode first")
            // Skips to grounding
            Button {
                guard let mode = selectedMode else { return }
                NotesStore.shared.currentNotes = nil
                currentScreen = .grounding(mode)
            } label: {
                Text("Quick Start")
                    .font(AppTheme.Fonts.secondaryButton)
                    .foregroundColor(canStart ? AppTheme.secondaryText : AppTheme.mutedText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.button)
                            .stroke(canStart ? AppTheme.border : Color.clear,
                                    lineWidth: 1)
                    )
            }
            .disabled(!canStart)
            .accessibilityHint(canStart
                               ? "Starts your session immediately without notes"
                               : "Select a practice mode first")
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.sm)
        .padding(.bottom, AppTheme.Spacing.xxl)
        .background(
            LinearGradient(
                colors: [AppTheme.background.opacity(0), AppTheme.background],
                startPoint: .top,
                endPoint: .center
            )
            .frame(height: 30)
            .offset(y: -30),
            alignment: .top
        )
    }
}

#Preview {
    let audioManager = AudioManager()
    
    let _ = {
        audioManager.recordings = [
            Recording(
                id: UUID(),
                url: URL(fileURLWithPath: "/dev/null"),
                date: Date().addingTimeInterval(-172800),
                duration: 125.2,
                speakingTime: 98.1,
                pauses: [0.5, 1.2, 0.8],
                notes: "Interview practice"
            )
        ]
    }()
    
    HomeView(
        currentScreen: .constant(.home),
        audioManager: audioManager
    )
}
