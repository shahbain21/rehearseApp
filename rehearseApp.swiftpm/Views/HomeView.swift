//
//  HomeView.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/1/26.
//

import SwiftUI

struct HomeView: View {
    @Binding var currentScreen: AppScreen
    // ADDED: Need access to AudioManager to pull the most recent recording
    @ObservedObject var audioManager: AudioManager
    @State private var selectedMode: PracticeMode? = nil
    @State private var appeared = false
    @State private var motivationalLine: String = ""
    
    private let motivationalLines = [
        "Confidence comes with reps.",
        "Every practice counts.",
        "Your voice matters — use it.",
        "Progress, not perfection."
    ]
    
    private var canStart: Bool {
        selectedMode != nil
    }
    
    // Pulls the most recent recording, sorted by date
    private var lastRecording: Recording? {
        audioManager.recordings
            .sorted { $0.date > $1.date }
            .first
    }
    
    // Time-based greeting
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning 👋"
        case 12..<17: return "Good afternoon 👋"
        case 17..<22: return "Good evening 👋"
        default:      return "Hey there 👋"
        }
    }
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                topBar
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        greetingSection
                        if let recording = lastRecording {
                            lastSessionCard(recording)
                        }
                        modeList
                    }
                    .padding(.bottom, AppTheme.Spacing.lg)
                }
                
                actionButtons
            }
        }
        .onAppear {
            withAnimation {
                appeared = true
            }
            motivationalLine = motivationalLines.randomElement()
            ?? motivationalLines[0]
        }
    }
    
    // Top Bar
    private var topBar: some View {
        HStack {
            Text("Rehearse")
                .font(AppTheme.Fonts.navTitle)
                .foregroundColor(AppTheme.primaryText)
            
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
    
    // Greeting
    private var greetingSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Text(greeting)
                .font(AppTheme.Fonts.screenTitle)
                .foregroundColor(AppTheme.primaryText)
            
            Text(motivationalLine)
                .font(AppTheme.Fonts.screenSubtitle)
                .foregroundColor(AppTheme.tertiaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, AppTheme.Spacing.md)
    }
    
    // Last Session Card
    private func lastSessionCard(_ recording: Recording) -> some View {
        Button {
            currentScreen = .feedback(recording)
        } label: {
            HStack(spacing: AppTheme.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(AppTheme.accentMuted)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: recording.mode?.icon ?? "waveform")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(AppTheme.accent)
                }
                
                // Session details
                VStack(alignment: .leading, spacing: 2) {
                    Text("Last Session")
                        .font(AppTheme.Fonts.smallLabel)
                        .foregroundColor(AppTheme.tertiaryText)
                    
                    // When it was recorded
                    let modeText = recording.mode?.displayName ?? ""
                                    let separator = modeText.isEmpty ? "" : " · "
                                    Text("\(modeText)\(separator)\(formatDuration(recording.duration)) · \(recording.pauses.count) pauses · \(timeAgo(recording.date))")
                                        .font(AppTheme.Fonts.caption)
                                        .foregroundColor(AppTheme.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.accent.opacity(0.4))
            }
            .padding(AppTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                    .fill(AppTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PressableButtonStyle())
        .padding(.horizontal, AppTheme.Spacing.lg)
        .accessibilityLabel("Last session: \(formatDuration(recording.duration)), \(recording.pauses.count) pauses, \(timeAgo(recording.date)). Tap to view history.")
    }
    
    // Mode List
    private var modeList: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            
            // Section label
            HStack {
                Text("PRACTICE MODE")
                    .font(AppTheme.Fonts.smallLabel)
                    .foregroundColor(AppTheme.tertiaryText)
                    .tracking(0.8)
                Spacer()
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            
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
                // Staggered entrance animation
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
            .disabled(!canStart)
            .accessibilityHint(canStart
                               ? "Opens the notes editor before your session"
                               : "Select a practice mode first")
            
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
    
    
    // Recording Duration formatting
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
    
    // How long ago it was recorded
    private func timeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
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
