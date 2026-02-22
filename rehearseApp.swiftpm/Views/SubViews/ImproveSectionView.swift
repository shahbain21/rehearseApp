//
//  ImproveSectionView.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 2/20/26.
//


import SwiftUI

struct ImproveSection: View {
    let feedback: PresentationFeedback
    let onReflect: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Practice exercises
            VStack(alignment: .leading, spacing: 12) {
                Text("Recommended Exercises")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
                
                ForEach(feedback.practiceExercises) { exercise in
                    ExerciseCard(exercise: exercise)
                }
            }
            
            // Improvement insights
            let improvementInsights = feedback.insights.filter { $0.type == .improvement }
            if !improvementInsights.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Focus Areas")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                    
                    ForEach(improvementInsights) { insight in
                        InsightRow(insight: insight)
                    }
                }
            }
            
            // Reflect button
            Button(action: onReflect) {
                HStack {
                    Image(systemName: "brain.head.profile")
                    Text("Reflect on This Session")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.blue)
                .cornerRadius(14)
            }
            
            // Practice again button
            Button {
                // Could navigate back to recording
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Practice Again")
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}

// MARK: - Exercise Card

struct ExerciseCard: View {
    let exercise: PracticeExercise
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: exercise.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(exercise.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(exercise.duration)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(6)
                }
                
                Text(exercise.description)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
    }
}

// MARK: - Preview

#Preview("Feedback View") {
    let recording = Recording(
        id: UUID(),
        url: URL(fileURLWithPath: "/dev/null"),
        date: Date(),
        duration: 125,
        speakingTime: 85,
        pauses: [0.4, 0.8, 1.2, 0.6, 2.5, 0.9, 1.1, 0.5, 3.2, 0.7],
        notes: "My presentation notes"
    )

    FeedbackView(
        currentScreen: .constant(.feedback(recording)),
        recording: recording,
        audioManager: AudioManager()
    )
}
