//
//  FeedbackView.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/1/26.
//

import SwiftUI

// FeedbackView

struct FeedbackView: View {
    @Binding var currentScreen: AppScreen
    let recording: Recording
    @ObservedObject var audioManager: AudioManager

    @State private var feedback: PresentationFeedback?
    @State private var isTranscribing = false
    @State private var transcriptError: String?
    @State private var transcript: TranscriptResult?

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            // Loading until feedback is generated
            if let feedback {
                VStack(spacing: 0) {
                    topBar
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
                        // Appears of the transcription fails
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
                        VStack(spacing: AppTheme.Spacing.lg) {
                            // Provide score for performance
                            ScoreCard(
                                score: feedback.overallScore,
                                tone: feedback.tone,
                                duration: feedback.durationText
                            )

                            // An overall summary
                            Text(feedback.summary)
                                .font(AppTheme.Fonts.screenSubtitle)
                                .foregroundColor(AppTheme.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, AppTheme.Spacing.lg)

                            // Expandable metric cards
                            ForEach(feedback.metrics, id: \.name) { metric in
                                ExpandableMetricCard(metric: metric)
                            }

                            // Vocal Energy metrics
                            if let samples = recording.volumeSamples, !samples.isEmpty {
                                ExpandableVocalEnergyCard(samples: samples)
                            }

                            // Transcript-based cards
                            if let transcript {
                                ExpandableFillerWordCard(
                                    result: FillerWordAnalyzer.analyze(transcript)
                                )

                                ExpandableWPMCard(
                                    result: WPMAnalyzer.analyze(transcript)
                                )

                                ExpandableRepeatedPhraseCard(
                                    result: RepeatedPhraseAnalyzer.analyze(transcript)
                                )
                            }

                            // Key insight based off stats
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                                Text("KEY INSIGHT")
                                    .font(AppTheme.Fonts.smallLabel)
                                    .foregroundColor(AppTheme.tertiaryText)
                                    .tracking(0.8)

                                ForEach(feedback.insights.prefix(2)) { insight in
                                    InsightRow(insight: insight)
                                }
                            }
                            .padding(AppTheme.Spacing.lg)
                            .background(AppTheme.cardBackground)
                            .cornerRadius(AppTheme.Radius.card)
                            bottomActions
                            // Shows any saved reflections
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
            // Generate feedback
            if feedback == nil {
                feedback = FeedbackGenerator.generate(from: recording)
            }
            // Reuse existing transcript
            if let existing = recording.transcript {
                transcript = existing
                return
            }

            guard recording.url.path != "/dev/null" else { return }

            // Small pause
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            guard !Task.isCancelled else { return }

            isTranscribing = true
            
            // Transcription occurs
            do {
                let result = try await SpeechAnalyzer.transcribe(url: recording.url)
                guard !Task.isCancelled else { return }
                // updates transcript and feedback
                audioManager.updateTranscript(result, for: recording)
                var updated = recording
                updated.transcript = result
                feedback = FeedbackGenerator.generate(from: updated)
                transcript = result
                isTranscribing = false
            } catch {
                // if it fails, show fail message
                transcriptError = error.localizedDescription
                isTranscribing = false
                print("Transcription failed:", error)
            }
        }
    }

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
            // Button to play the audio
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


    private var bottomActions: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Button to add reflection
            Button {
                currentScreen = .reflection(recording)
            } label: {
                HStack {
                    Image(systemName: "brain.head.profile")
                    Text("Reflect on This Session")
                }
                .font(AppTheme.Fonts.buttonLabel)
                .foregroundColor(AppTheme.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.button)
                        .fill(AppTheme.accent)
                )
            }
            .accessibilityHint("Opens the reflection screen for this session")
            // Button to record again
            Button {
                if let mode = recording.mode {
                    currentScreen = .grounding(mode)
                } else {
                    currentScreen = .home
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Practice Again")
                }
                .font(AppTheme.Fonts.secondaryButton)
                .foregroundColor(AppTheme.secondaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.button)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
            }
            .accessibilityHint("Starts a new practice session with the same mode")
        }
    }
}


// Preview

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
