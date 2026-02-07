//
//  ReflectionView.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/1/26.
//

import SwiftUI

struct ReflectionView: View {
    @Binding var currentScreen: AppScreen
    let recording: Recording?
    
    @State private var selectedMood: ReflectionMood?
    @State private var hardPart = ""
    @State private var goodPart = ""
    @State private var nextTimeFocus = ""
    @State private var showingPrompts = false
    @FocusState private var focusedField: ReflectionField?
    
    enum ReflectionField {
        case hard, good, next
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
                .onTapGesture {
                    focusedField = nil
                }

            VStack(spacing: 0) {
                
                // Top bar
                HStack {
                    Button {
                        currentScreen = .history
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Text("Reflect")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Prompts help button
                    Button {
                        showingPrompts = true
                    } label: {
                        Image(systemName: "lightbulb")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 16)

                ScrollView {
                    VStack(spacing: 24) {
                        
                        // Header
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.purple.opacity(0.15))
                                    .frame(width: 70, height: 70)
                                
                                Image(systemName: "brain.head.profile")
                                    .font(.system(size: 28, weight: .medium))
                                    .foregroundColor(.purple)
                            }
                            
                            Text("Take a moment to reflect")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white)

                            Text("A few words is enough.\nThis helps you grow faster.")
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.5))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 8)

                        // Mood selector
                        VStack(alignment: .leading, spacing: 12) {
                            Text("How did that feel?")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))
                            
                            HStack(spacing: 12) {
                                ForEach(ReflectionMood.allCases, id: \.self) { mood in
                                    MoodButton(
                                        mood: mood,
                                        isSelected: selectedMood == mood
                                    ) {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedMood = mood
                                        }
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)

                        // Reflection questions
                        VStack(spacing: 16) {
                            ReflectionTextField(
                                title: "What felt hardest?",
                                placeholder: "e.g., Staying on track, not rushing...",
                                text: $hardPart,
                                icon: "mountain.2",
                                color: .orange
                            )
                            .focused($focusedField, equals: .hard)

                            ReflectionTextField(
                                title: "What went better than expected?",
                                placeholder: "e.g., I stayed calm, good energy...",
                                text: $goodPart,
                                icon: "star",
                                color: .green
                            )
                            .focused($focusedField, equals: .good)

                            ReflectionTextField(
                                title: "What will you focus on next time?",
                                placeholder: "e.g., Slower pace, more pauses...",
                                text: $nextTimeFocus,
                                icon: "target",
                                color: .blue
                            )
                            .focused($focusedField, equals: .next)
                        }

                        // Quick tags
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quick tags (tap to add)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))
                            
                            FlowLayout(spacing: 8) {
                                ForEach(quickTags, id: \.self) { tag in
                                    QuickTagButton(tag: tag) {
                                        addTag(tag)
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)

                        // Session summary (if recording provided)
                        if let recording = recording {
                            SessionSummaryCard(recording: recording)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 120)
                }

                // Bottom action button
                VStack(spacing: 12) {
                    Button {
                        saveReflection()
                        currentScreen = .history
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Finish Session")
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(14)
                    }
                    
                    Button {
                        currentScreen = .history
                    } label: {
                        Text("Skip reflection")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
                .background(
                    LinearGradient(
                        colors: [
                            AppTheme.background.opacity(0),
                            AppTheme.background,
                            AppTheme.background
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 100)
                    .allowsHitTesting(false)
                    .offset(y: -50)
                )
            }
        }
        .sheet(isPresented: $showingPrompts) {
            ReflectionPromptsSheet()
        }
    }
    
    // MARK: - Quick Tags
    
    private var quickTags: [String] {
        [
            "Felt rushed",
            "Good energy",
            "Lost track",
            "Stayed calm",
            "Need more prep",
            "Strong opening",
            "Weak ending",
            "Good pace",
            "Too many pauses",
            "Confident"
        ]
    }
    
    private func addTag(_ tag: String) {
        // Add to the most relevant field based on the tag
        let positiveKeywords = ["good", "strong", "confident", "calm"]
        let negativeKeywords = ["rushed", "lost", "need", "weak", "too many"]
        
        let tagLower = tag.lowercased()
        
        if positiveKeywords.contains(where: { tagLower.contains($0) }) {
            if !goodPart.isEmpty && !goodPart.hasSuffix(" ") {
                goodPart += ", "
            }
            goodPart += tag
        } else if negativeKeywords.contains(where: { tagLower.contains($0) }) {
            if !hardPart.isEmpty && !hardPart.hasSuffix(" ") {
                hardPart += ", "
            }
            hardPart += tag
        } else {
            if !nextTimeFocus.isEmpty && !nextTimeFocus.hasSuffix(" ") {
                nextTimeFocus += ", "
            }
            nextTimeFocus += tag
        }
    }
    
    private func saveReflection() {
        // TODO: Save reflection to recording or separate storage
        // For now, just print
        print("Reflection saved:")
        print("Mood: \(selectedMood?.label ?? "None")")
        print("Hard: \(hardPart)")
        print("Good: \(goodPart)")
        print("Next: \(nextTimeFocus)")
    }
}

// MARK: - Reflection Mood

enum ReflectionMood: CaseIterable {
    case great
    case good
    case okay
    case rough
    
    var emoji: String {
        switch self {
        case .great: return "🔥"
        case .good: return "😊"
        case .okay: return "😐"
        case .rough: return "😤"
        }
    }
    
    var label: String {
        switch self {
        case .great: return "Great"
        case .good: return "Good"
        case .okay: return "Okay"
        case .rough: return "Rough"
        }
    }
    
    var color: Color {
        switch self {
        case .great: return .green
        case .good: return .cyan
        case .okay: return .yellow
        case .rough: return .orange
        }
    }
}

// MARK: - Mood Button

struct MoodButton: View {
    let mood: ReflectionMood
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(mood.emoji)
                    .font(.system(size: 28))
                
                Text(mood.label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? mood.color : .white.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? mood.color.opacity(0.15) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? mood.color.opacity(0.5) : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Reflection Text Field

struct ReflectionTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.3))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                }
                
                TextEditor(text: $text)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
            }
            .frame(minHeight: 80)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(text.isEmpty ? 0 : 0.3), lineWidth: 1)
            )
        }
        .padding(16)
        .background(Color.white.opacity(0.03))
        .cornerRadius(16)
    }
}

// MARK: - Quick Tag Button

struct QuickTagButton: View {
    let tag: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(tag)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.1))
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Flow Layout (for tags)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
                
                self.size.width = max(self.size.width, x)
            }
            
            self.size.height = y + rowHeight
        }
    }
}

// MARK: - Session Summary Card

struct SessionSummaryCard: View {
    let recording: Recording
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session Summary")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
            
            HStack(spacing: 16) {
                SummaryItem(
                    icon: "clock",
                    value: formatDuration(recording.duration),
                    label: "Duration"
                )
                
                SummaryItem(
                    icon: "waveform",
                    value: "\(Int(recording.speakingRatio * 100))%",
                    label: "Speaking"
                )
                
                SummaryItem(
                    icon: "pause.circle",
                    value: "\(recording.pauses.count)",
                    label: "Pauses"
                )
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct SummaryItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.blue)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Reflection Prompts Sheet

struct ReflectionPromptsSheet: View {
    @Environment(\.dismiss) var dismiss
    
    let prompts = [
        ReflectionPrompt(
            category: "Delivery",
            questions: [
                "Did I speak at a comfortable pace?",
                "Were my pauses intentional or hesitant?",
                "Did I sound confident?"
            ]
        ),
        ReflectionPrompt(
            category: "Content",
            questions: [
                "Did I cover all my main points?",
                "Were my ideas organized logically?",
                "Did I stay on topic?"
            ]
        ),
        ReflectionPrompt(
            category: "Mindset",
            questions: [
                "How did I feel before starting?",
                "What triggered any nervousness?",
                "When did I feel most confident?"
            ]
        ),
        ReflectionPrompt(
            category: "Growth",
            questions: [
                "What's one thing I did better than last time?",
                "What's one thing I want to improve?",
                "What would I tell someone else in my position?"
            ]
        )
    ]
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Handle
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 36, height: 5)
                    .padding(.top, 10)
                
                // Header
                HStack {
                    Text("Reflection Prompts")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .padding()
                
                // Prompts
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(prompts, id: \.category) { prompt in
                            PromptCategoryCard(prompt: prompt)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }
}

struct ReflectionPrompt {
    let category: String
    let questions: [String]
}

struct PromptCategoryCard: View {
    let prompt: ReflectionPrompt
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(prompt.category)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.blue)
            
            ForEach(prompt.questions, id: \.self) { question in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.top, 6)
                    
                    Text(question)
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

// MARK: - Previews

#Preview("Reflection View") {
    let recording = Recording(
        id: UUID(),
        url: URL(fileURLWithPath: "/dev/null"),
        date: Date(),
        duration: 125,
        speakingTime: 85,
        pauses: [0.4, 0.8, 1.2, 0.6, 2.5],
        notes: nil
    )
    
    ReflectionView(
        currentScreen: .constant(.reflection(recording)),  // ✅ Pass recording
        recording: recording
    )
}

#Preview("Reflection View - No Recording") {
    ReflectionView(
        currentScreen: .constant(.reflection(nil)),  // ✅ Pass nil
        recording: nil
    )
}

#Preview("Prompts Sheet") {
    ReflectionPromptsSheet()
}
