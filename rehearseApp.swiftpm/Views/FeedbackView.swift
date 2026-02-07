//
//  FeedbackView.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/1/26.
//
import SwiftUI

struct FeedbackView: View {
    @Binding var currentScreen: AppScreen
    let recording: Recording
    @ObservedObject var audioManager: AudioManager
    
    @State private var selectedTab: FeedbackTab = .overview

    private var feedback: PresentationFeedback {
        FeedbackGenerator.generate(from: recording)
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                
                // Top bar
                HStack {
                    Button {
                        currentScreen = .history
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Text("Feedback")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Play recording button
                    Button {
                        audioManager.togglePlayback(for: recording)
                    } label: {
                        Image(systemName: audioManager.currentlyPlayingID == recording.id ? "stop.fill" : "play.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
                
                // Tab selector
                FeedbackTabSelector(selectedTab: $selectedTab)
                    .padding(.horizontal)
                    .padding(.bottom, 16)

                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        switch selectedTab {
                        case .overview:
                            OverviewSection(feedback: feedback, recording: recording)
                        case .details:
                            DetailsSection(feedback: feedback)
                        case .improve:
                            ImproveSection(feedback: feedback, onReflect: {
                                currentScreen = .reflection(recording)
                            })
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

// MARK: - Feedback Tabs

enum FeedbackTab: String, CaseIterable {
    case overview = "Overview"
    case details = "Details"
    case improve = "Improve"
}

struct FeedbackTabSelector: View {
    @Binding var selectedTab: FeedbackTab
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(FeedbackTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.5))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(selectedTab == tab ? Color.blue : Color.white.opacity(0.08))
                        )
                }
            }
        }
    }
}

// MARK: - Overview Section

struct OverviewSection: View {
    let feedback: PresentationFeedback
    let recording: Recording
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Score Card
            ScoreCard(
                score: feedback.overallScore,
                tone: feedback.tone,
                duration: feedback.durationText
            )
            
            // Summary
            Text(feedback.summary)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Pace indicator
            PaceIndicator(category: feedback.paceCategory, description: feedback.paceDescription)
            
            // Quick metrics
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                QuickMetricCard(
                    icon: "waveform",
                    title: "Speaking",
                    value: "\(Int(recording.speakingRatio * 100))%",
                    color: .blue
                )
                
                QuickMetricCard(
                    icon: "pause.circle",
                    title: "Avg Pause",
                    value: String(format: "%.1fs", recording.averagePauseDuration),
                    color: .cyan
                )
                
                QuickMetricCard(
                    icon: "text.alignleft",
                    title: "Avg Segment",
                    value: String(format: "%.1fs", recording.averageSpeakingSegmentLength),
                    color: .purple
                )
                
                QuickMetricCard(
                    icon: "exclamationmark.circle",
                    title: "Long Pauses",
                    value: "\(recording.longPauseCount)",
                    color: recording.longPauseCount > 2 ? .orange : .green
                )
            }
            
            // Top insights preview
            VStack(alignment: .leading, spacing: 12) {
                Text("Key Insights")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
                
                ForEach(feedback.insights.prefix(3)) { insight in
                    InsightRow(insight: insight)
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
    }
}

// MARK: - Score Card

struct ScoreCard: View {
    let score: Int
    let tone: FeedbackTone
    let duration: String
    
    var body: some View {
        VStack(spacing: 16) {
            // Score ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 12)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: CGFloat(score) / 100)
                    .stroke(
                        tone.color,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("\(score)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("/ 100")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            // Tone badge
            HStack(spacing: 6) {
                Image(systemName: tone.icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(tone.label)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(tone.color)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(tone.color.opacity(0.15))
            .cornerRadius(20)
            
            // Duration
            Text(duration)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
    }
}

// MARK: - Pace Indicator

struct PaceIndicator: View {
    let category: PaceCategory
    let description: String
    
    var body: some View {
        VStack(spacing: 12) {
            // Pace scale
            HStack(spacing: 4) {
                ForEach(["Too Slow", "Slow", "Ideal", "Fast", "Too Fast"], id: \.self) { label in
                    let isActive = label == category.label ||
                        (label == "Very Slow" && category == .tooSlow) ||
                        (label == "Very Fast" && category == .tooFast)
                    
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(isActive ? category.color : Color.white.opacity(0.15))
                            .frame(height: 8)
                        
                        if isActive {
                            Text(category.label)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(category.color)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            Text(description)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

// MARK: - Quick Metric Card

struct QuickMetricCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
    }
}

// MARK: - Insight Row

struct InsightRow: View {
    let insight: FeedbackInsight
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: insight.type.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(insight.type.color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(insight.description)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(insight.type.color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Details Section

struct DetailsSection: View {
    let feedback: PresentationFeedback
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Detailed metrics
            VStack(alignment: .leading, spacing: 12) {
                Text("Detailed Metrics")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
                
                ForEach(feedback.metrics, id: \.name) { metric in
                    DetailedMetricRow(metric: metric)
                }
            }
            
            // Pause distribution
            PauseDistributionCard(distribution: feedback.pauseDistribution)
            
            // All insights
            VStack(alignment: .leading, spacing: 12) {
                Text("All Insights")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
                
                ForEach(feedback.insights) { insight in
                    InsightRow(insight: insight)
                }
            }
        }
    }
}

// MARK: - Detailed Metric Row

struct DetailedMetricRow: View {
    let metric: DetailedMetric
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: metric.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(metric.rating.color)
                        .frame(width: 24)
                    
                    Text(metric.name)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text(metric.value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            HStack {
                Text(metric.description)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
                
                Spacer()
                
                Text(metric.rating.label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(metric.rating.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(metric.rating.color.opacity(0.15))
                    .cornerRadius(6)
            }
            
            if let tip = metric.tip {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 10))
                    Text(tip)
                        .font(.system(size: 12))
                }
                .foregroundColor(.yellow)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
    }
}

// MARK: - Pause Distribution Card

struct PauseDistributionCard: View {
    let distribution: PauseDistribution
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Pause Distribution")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
            
            // Bar chart
            HStack(alignment: .bottom, spacing: 12) {
                PauseBar(label: "<0.5s", count: distribution.shortPauses, total: distribution.total, color: .green)
                PauseBar(label: "0.5-1.5s", count: distribution.mediumPauses, total: distribution.total, color: .cyan)
                PauseBar(label: "1.5-3s", count: distribution.longPauses, total: distribution.total, color: .yellow)
                PauseBar(label: ">3s", count: distribution.veryLongPauses, total: distribution.total, color: .orange)
            }
            .frame(height: 100)
            
            // Analysis
            Text(distribution.analysis)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

struct PauseBar: View {
    let label: String
    let count: Int
    let total: Int
    let color: Color
    
    private var height: CGFloat {
        guard total > 0 else { return 10 }
        return max(10, CGFloat(count) / CGFloat(total) * 80)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(count)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
            
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(height: height)
            
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Improve Section

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

#Preview("Feedback - Needs Work") {
    let recording = Recording(
        id: UUID(),
        url: URL(fileURLWithPath: "/dev/null"),
        date: Date(),
        duration: 60,
        speakingTime: 25,
        pauses: [2.1, 3.5, 2.8, 4.2, 1.9, 2.5],
        notes: nil
    )

    FeedbackView(
        currentScreen: .constant(.feedback(recording)),
        recording: recording,
        audioManager: AudioManager()
    )
}
