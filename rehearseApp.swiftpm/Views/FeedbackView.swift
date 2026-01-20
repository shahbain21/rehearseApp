//
//  FeedbackView.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/1/26.
//
import SwiftUI

struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.gray)

            Text(value)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity, minHeight: 90)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8)
    }
}

struct FeedbackView: View {
    @Binding var currentScreen: AppScreen
    let recording: Recording

    private var feedback: PresentationFeedback {
        FeedbackGenerator.generate(from: recording)
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text(feedback.durationText)
                .font(.system(size: 20, weight: .medium))

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 16
            ) {
                StatCard(
                    title: "Speaking Ratio",
                    value: "\(Int(recording.speakingRatio * 100))%"
                )

                StatCard(
                    title: "Avg Pause",
                    value: String(format: "%.1fs", recording.averagePauseDuration)
                )

                StatCard(
                    title: "Long Pauses",
                    value: "\(recording.longPauseCount)"
                )

                StatCard(
                    title: "Avg Segment",
                    value: String(format: "%.1fs", recording.averageSpeakingSegmentLength)
                )
            }

            Text(feedback.tone.label)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(feedback.tone.color.opacity(0.15))
                .foregroundColor(feedback.tone.color)
                .clipShape(Capsule())

            VStack(alignment: .leading, spacing: 8) {
                Text("What went well")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)

                Text(feedback.whatWentWell)
                    .foregroundColor(.primary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)

            VStack(alignment: .leading, spacing: 8) {
                Text("For next time")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)

                Text(feedback.improvementSuggestion)
                    .foregroundColor(.primary)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)

            Button("Reflect") {
                currentScreen = .reflection
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
    }
}


#Preview {
    let recording = Recording(
        id: UUID(),
        url: URL(fileURLWithPath: "/dev/null"),
        date: Date(),
        duration: 72,
        speakingTime: 48,
        pauses: [0.8, 1.1, 2.4],
        notes: nil
    )
    
    FeedbackView(
        currentScreen: .constant(.feedback),
        recording: recording
    )
}
