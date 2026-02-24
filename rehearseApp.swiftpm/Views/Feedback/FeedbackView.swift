//
//  FeedbackView.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/1/26.
//

import Speech
import SwiftUI

// MARK: - FeedbackView

struct FeedbackView: View {
    @Binding var currentScreen: AppScreen
    let recording: Recording
    @ObservedObject var audioManager: AudioManager

    @State private var selectedTab: FeedbackTab = .overview
    @State private var feedback: PresentationFeedback?
    @State private var isTranscribing = false
    @State private var transcriptError: String?

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            if let feedback {
                VStack(spacing: 0) {

                    topBar

                    FeedbackTabSelector(selectedTab: $selectedTab)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.bottom, AppTheme.Spacing.lg)

                    // Transcription status
                    if isTranscribing {
                        HStack(spacing: 8) {
                            ProgressView()
                                .tint(AppTheme.accent)
                                .scaleEffect(0.8)
                            Text("Analyzing speech…")
                                .font(AppTheme.Fonts.smallLabel)
                                .foregroundColor(AppTheme.tertiaryText)
                        }
                        .padding(.bottom, AppTheme.Spacing.sm)
                    } else if transcriptError != nil {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 12))
                            Text("Speech analysis unavailable")
                                .font(AppTheme.Fonts.smallLabel)
                        }
                        .foregroundColor(.orange)
                        .padding(.bottom, AppTheme.Spacing.sm)
                    }

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: AppTheme.Spacing.xl) {
                            switch selectedTab {
                            case .overview:
                                OverviewSection(
                                    feedback: feedback,
                                    recording: recording
                                )
                            case .details:
                                DetailsSection(
                                    feedback: feedback,
                                    recording: recording
                                )
                            case .improve:
                                ImproveSection(
                                    feedback: feedback,
                                    onReflect: {
                                        currentScreen = .reflection(recording)
                                    },
                                    onPracticeAgain: {
                                        if let mode = recording.mode {
                                            currentScreen = .grounding(mode)
                                        } else {
                                            currentScreen = .home
                                        }
                                    }
                                )
                            }

                            if let reflection = recording.reflection {
                                ReflectionSummaryCard(reflection: reflection)
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.bottom, AppTheme.Spacing.xxl)
                    }
                }
            } else {
                ProgressView()
                    .tint(.white)
            }
        }
        .task {
            if feedback == nil {
                feedback = FeedbackGenerator.generate(from: recording)
            }

            guard recording.url.path != "/dev/null" else { return }
            guard recording.transcript == nil else { return }

            try? await Task.sleep(nanoseconds: 2_000_000_000)
            guard !Task.isCancelled else { return }

            isTranscribing = true
            defer { isTranscribing = false }

            do {
                let transcript = try await SpeechAnalyzer.transcribe(url: recording.url)

                guard !Task.isCancelled else { return }

                audioManager.updateTranscript(transcript, for: recording)

                var updated = recording
                updated.transcript = transcript
                feedback = FeedbackGenerator.generate(from: updated)
            } catch {
                transcriptError = error.localizedDescription
                print("Transcription failed:", error)
            }
        }
    }
    
    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button {
                currentScreen = .history
            } label: {
                Image(systemName: "chevron.left")
                    .font(AppTheme.Fonts.iconFont)
                    .foregroundColor(AppTheme.secondaryText)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Back to history")

            Spacer()

            Text("Feedback")
                .font(AppTheme.Fonts.navTitle)
                .foregroundColor(AppTheme.primaryText)

            Spacer()

            Button {
                audioManager.togglePlayback(for: recording)
            } label: {
                Image(systemName: audioManager.currentlyPlayingID == recording.id
                      ? "stop.fill" : "play.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.primaryText)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.accent)
                    .cornerRadius(AppTheme.Spacing.sm)
            }
            .accessibilityLabel(
                audioManager.currentlyPlayingID == recording.id
                ? "Stop playback" : "Play recording"
            )
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.lg)
    }
}

// MARK: - Feedback Tab

enum FeedbackTab: String, CaseIterable {
    case overview = "Overview"
    case details = "Details"
    case improve = "Improve"
}

// MARK: - Tab Selector

struct FeedbackTabSelector: View {
    @Binding var selectedTab: FeedbackTab

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            ForEach(FeedbackTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(AppTheme.Fonts.smallLabel)
                        .foregroundColor(selectedTab == tab
                                         ? AppTheme.primaryText
                                         : AppTheme.tertiaryText)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(selectedTab == tab
                                      ? AppTheme.accent
                                      : AppTheme.cardBackground)
                        )
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
    }
}

// MARK: - Previews

#Preview("Feedback View") {
    let recording = Recording(
        id: UUID(),
        url: URL(fileURLWithPath: "/dev/null"),
        date: Date(),
        duration: 125,
        speakingTime: 85,
        pauses: [0.4, 0.8, 1.2, 0.6, 2.5, 0.9, 1.1, 0.5, 3.2, 0.7],
        notes: "My presentation notes",
        volumeSamples: [-35, -28, -42, -30, -25, -38, -32, -27, -40, -33, -29, -36]
    )

    FeedbackView(
        currentScreen: .constant(.feedback(recording)),
        recording: recording,
        audioManager: AudioManager()
    )
}

#Preview("Feedback - With Reflection") {
    let recording: Recording = {
        var r = Recording(
            id: UUID(),
            url: URL(fileURLWithPath: "/dev/null"),
            date: Date(),
            duration: 125,
            speakingTime: 85,
            pauses: [0.4, 0.8, 1.2, 0.6, 2.5],
            notes: "My notes"
        )
        r.reflection = Reflection(
            mood: "Great",
            tags: ["Good energy", "Stayed calm", "Strong opening"],
            note: "Felt really prepared this time.",
            date: Date()
        )
        return r
    }()

    FeedbackView(
        currentScreen: .constant(.feedback(recording)),
        recording: recording,
        audioManager: AudioManager()
    )
}

#Preview("Feedback - Needs Work") {
    let recording = Recording(
        id: UUID(),
        url: URL(fileURLWithPath: "/dev/null"),
        date: Date(),
        duration: 60,
        speakingTime: 25,
        pauses: [2.1, 3.5, 2.8, 4.2, 1.9, 2.5],
        notes: nil,
        volumeSamples: [-42, -44, -43, -45, -42, -44, -43, -42]
    )

    FeedbackView(
        currentScreen: .constant(.feedback(recording)),
        recording: recording,
        audioManager: AudioManager()
    )
}
