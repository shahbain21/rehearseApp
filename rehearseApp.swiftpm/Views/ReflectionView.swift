//
//  ReflectionView.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/1/26.
//

import SwiftUI

struct Reflection: Codable {
    let mood: String
    let tags: [String]
    let note: String         
    let date: Date
}

struct ReflectionView: View {
    @Binding var currentScreen: AppScreen
    let recording: Recording?
    @ObservedObject var audioManager: AudioManager
    
    @State private var selectedMood: ReflectionMood?
    @State private var note = ""
    @State private var selectedTags: Set<String> = []
    @State private var showingPrompts = false
    @FocusState private var isNoteFocused: Bool

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
                .onTapGesture {
                    isNoteFocused = false
                }

            VStack(spacing: 0) {
                topBar
                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        performanceHeader
                        moodSection
                        tagsSection
                        noteSection
                        // Session summary
                        if let recording = recording {
                            SessionSummaryCard(recording: recording)
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.bottom, 140)
                }
                actionButtons
            }
        }
        .sheet(isPresented: $showingPrompts) {
            ReflectionPromptsSheet()
        }
    }
    
    private var topBar: some View {
        HStack {
            Button {
                currentScreen = .history
            } label: {
                Image(systemName: "xmark")
                    .font(AppTheme.Fonts.iconFont)
                    .foregroundColor(AppTheme.secondaryText)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Close reflection")
            
            Spacer()
            
            Text("Reflect")
                .font(AppTheme.Fonts.navTitle)
                .foregroundColor(AppTheme.primaryText)
            
            Spacer()
            
            // Provides questions to reflect over
            Button {
                showingPrompts = true
            } label: {
                Image(systemName: "lightbulb")
                    .font(AppTheme.Fonts.iconFont)
                    .foregroundColor(AppTheme.secondaryText)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Show reflection prompts")
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.lg)
    }
    
    // Performance Header
    private var performanceHeader: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(AppTheme.accentMuted)
                    .frame(width: 70, height: 70)
                
                Image(systemName: performanceIcon)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(AppTheme.accent)
            }
            
            Text(performanceHeadline)
                .font(AppTheme.Fonts.screenTitle)
                .foregroundColor(AppTheme.primaryText)

            Text(performanceSubtitle)
                .font(AppTheme.Fonts.screenSubtitle)
                .foregroundColor(AppTheme.tertiaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.top, AppTheme.Spacing.sm)
    }
    
    // Choose icon based on performance
    private var performanceIcon: String {
        guard let recording = recording else { return "brain.head.profile" }
        let ratio = recording.speakingRatio
        if ratio > 0.75 { return "flame.fill" }
        if ratio > 0.5 { return "checkmark.seal.fill" }
        return "arrow.up.circle.fill"
    }
    
    // Generate headline from recording data
    private var performanceHeadline: String {
        guard let recording = recording else { return "Take a moment to reflect" }
        let ratio = recording.speakingRatio
        
        if ratio > 0.75 {
            return "Strong session 🔥"
        } else if ratio > 0.5 {
            return "Solid practice 👏"
        } else {
            return "Good effort 💪"
        }
    }
    
    // Generate subtitle from actual metrics
    private var performanceSubtitle: String {
        guard let recording = recording else {
            return "A few words is enough.\nThis helps you grow faster."
        }
        
        let speakingPercent = Int(recording.speakingRatio * 100)
        let pauseCount = recording.pauses.count
        let duration = Int(recording.duration)
        let minutes = duration / 60
        let seconds = duration % 60
        
        var parts: [String] = []
        
        // Duration
        if minutes > 0 {
            parts.append("You practiced for \(minutes)m \(seconds)s")
        } else {
            parts.append("You practiced for \(seconds) seconds")
        }
        
        // Speaking ratio insight
        if speakingPercent > 75 {
            parts.append("and spoke \(speakingPercent)% of the time — focused delivery.")
        } else if speakingPercent > 50 {
            parts.append("with a good balance of speaking and pauses.")
        } else {
            parts.append("with plenty of pauses to gather your thoughts.")
        }
        
        // Pause insight
        let longPauses = recording.pauses.filter { $0 > 2.0 }.count
        if longPauses > 0 {
            parts.append("\(longPauses) longer pause\(longPauses == 1 ? "" : "s") — those can be intentional or worth working on.")
        } else if pauseCount > 0 {
            parts.append("Your pauses were short and natural.")
        }
        
        return parts.joined(separator: " ")
    }
    
    // Selecting mood in emoji form
    private var moodSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("How did that feel?")
                .font(AppTheme.Fonts.smallLabel)
                .foregroundColor(AppTheme.tertiaryText)
                .tracking(0.5)
            
            HStack(spacing: AppTheme.Spacing.md) {
                ForEach(ReflectionMood.allCases, id: \.self) { mood in
                    MoodButton(
                        mood: mood,
                        isSelected: selectedMood == mood
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedMood = mood
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.Radius.card)
    }
    
    // Tags to summarize the session
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("What stood out?")
                .font(AppTheme.Fonts.smallLabel)
                .foregroundColor(AppTheme.tertiaryText)
                .tracking(0.5)
            
            FlowLayout(spacing: 8) {
                ForEach(quickTags, id: \.self) { tag in
                    QuickTagButton(
                        tag: tag,
                        isSelected: selectedTags.contains(tag)
                    ) {
                        toggleTag(tag)
                    }
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.Radius.card)
    }
    
    // Optional Notes section
    private var noteSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.accent)
                
                Text("Anything else?")
                    .font(AppTheme.Fonts.smallLabel)
                    .foregroundColor(AppTheme.tertiaryText)
                    .tracking(0.5)
                
                Spacer()
                
                Text("Optional")
                    .font(AppTheme.Fonts.smallLabel)
                    .foregroundColor(AppTheme.mutedText)
            }
            
            ZStack(alignment: .topLeading) {
                if note.isEmpty {
                    Text("A quick thought, something to remember, or nothing at all...")
                        .font(AppTheme.Fonts.screenSubtitle)
                        .foregroundColor(AppTheme.mutedText)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                }
                
                TextEditor(text: $note)
                    .font(AppTheme.Fonts.screenSubtitle)
                    .foregroundColor(AppTheme.primaryText)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 10)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .focused($isNoteFocused)
            }
            .frame(minHeight: 80)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.Radius.card)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                    .stroke(
                        isNoteFocused ? AppTheme.borderSelected : AppTheme.border,
                        lineWidth: 1
                    )
            )
        }
        .padding(AppTheme.Spacing.lg)
        .background(Color.white.opacity(0.03))
        .cornerRadius(AppTheme.Radius.card)
    }
    
    // Action Buttons
    private var actionButtons: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Button {
                saveReflection()
                currentScreen = .history
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Finish Session")
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
            .accessibilityHint("Saves your reflection and returns to history")
            
            Button {
                currentScreen = .history
            } label: {
                Text("Skip reflection")
                    .font(AppTheme.Fonts.secondaryButton)
                    .foregroundColor(AppTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.button)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
            }
            .accessibilityHint("Skips reflection and returns to history")
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.bottom, AppTheme.Spacing.xxl)
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
            .frame(height: 80)
            .allowsHitTesting(false)
            .offset(y: -40),
            alignment: .top
        )
    }
        
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
    
    private func toggleTag(_ tag: String) {
        withAnimation(.easeInOut(duration: 0.15)) {
            if selectedTags.contains(tag) {
                selectedTags.remove(tag)
            } else {
                selectedTags.insert(tag)
            }
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    // Saves reflection data to the recording
    private func saveReflection() {
        let reflection = Reflection(
            mood: selectedMood?.label ?? "None",
            tags: Array(selectedTags),
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            date: Date()
        )
        
        if let recording = recording {
            audioManager.saveReflection(reflection, for: recording)
        }
    }
}


enum ReflectionMood: CaseIterable {
    case great
    case good
    case okay
    case rough
    
    var emoji: String {
        switch self {
        case .great: return "🔥"
        case .good:  return "😊"
        case .okay:  return "😐"
        case .rough: return "😤"
        }
    }
    
    var label: String {
        switch self {
        case .great: return "Great"
        case .good:  return "Good"
        case .okay:  return "Okay"
        case .rough: return "Rough"
        }
    }
    
    var color: Color {
        switch self {
        case .great: return .green
        case .good:  return .cyan
        case .okay:  return .yellow
        case .rough: return .orange
        }
    }
}

struct MoodButton: View {
    let mood: ReflectionMood
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.sm) {
                Text(mood.emoji)
                    .font(.system(size: 28))
                
                Text(mood.label)
                    .font(AppTheme.Fonts.smallLabel)
                    .foregroundColor(isSelected ? mood.color : AppTheme.tertiaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                    .fill(isSelected ? mood.color.opacity(0.15) : AppTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                            .stroke(
                                isSelected ? mood.color.opacity(0.5) : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel("\(mood.label) mood")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}



struct QuickTagButton: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(tag)
                .font(AppTheme.Fonts.smallLabel)
                .foregroundColor(isSelected ? AppTheme.accent : AppTheme.secondaryText)
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? AppTheme.accentMuted : AppTheme.cardBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isSelected ? AppTheme.accent.opacity(0.4) : Color.clear,
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(tag)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}


struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    // Measure size
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    // Place view at calculated position
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(
                at: CGPoint(
                    x: bounds.minX + result.positions[index].x,
                    y: bounds.minY + result.positions[index].y
                ),
                proposal: .unspecified
            )
        }
    }
    
    // Finds the positions of the tags
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

// Session stats
struct SessionSummaryCard: View {
    let recording: Recording
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text("SESSION SUMMARY")
                .font(AppTheme.Fonts.smallLabel)
                .foregroundColor(AppTheme.tertiaryText)
                .tracking(0.8)
            
            HStack(spacing: AppTheme.Spacing.lg) {
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
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.Radius.card)
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
                .font(AppTheme.Fonts.iconFont)
                .foregroundColor(AppTheme.accent)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.primaryText)
            
            Text(label)
                .font(AppTheme.Fonts.smallLabel)
                .foregroundColor(AppTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }
}


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
                    .fill(AppTheme.mutedText)
                    .frame(width: 36, height: 5)
                    .padding(.top, 10)
                
                // Header
                HStack {
                    Text("Reflection Prompts")
                        .font(AppTheme.Fonts.screenTitle)
                        .foregroundColor(AppTheme.primaryText)
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.tertiaryText)
                            // ADDED: Proper tap target
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Close prompts")
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.top, AppTheme.Spacing.lg)
                
                // Prompts
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        ForEach(prompts, id: \.category) { prompt in
                            PromptCategoryCard(prompt: prompt)
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
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
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text(prompt.category)
                .font(AppTheme.Fonts.cardTitle)
                .foregroundColor(AppTheme.accent)
            
            ForEach(prompt.questions, id: \.self) { question in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .foregroundColor(AppTheme.mutedText)
                        .padding(.top, 6)
                    
                    Text(question)
                        .font(AppTheme.Fonts.screenSubtitle)
                        .foregroundColor(AppTheme.secondaryText)
                }
            }
        }
        .padding(AppTheme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.Radius.card)
    }
}

// Previews

#Preview("Reflection View") {
    let audioManager = AudioManager()
    
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
        currentScreen: .constant(.reflection(recording)),
        recording: recording,
        audioManager: audioManager
    )
}

#Preview("Reflection View - Short Session") {
    let audioManager = AudioManager()
    
    let recording = Recording(
        id: UUID(),
        url: URL(fileURLWithPath: "/dev/null"),
        date: Date(),
        duration: 30,
        speakingTime: 10,
        pauses: [0.4, 0.8, 3.2, 4.1],
        notes: nil
    )
    
    ReflectionView(
        currentScreen: .constant(.reflection(recording)),
        recording: recording,
        audioManager: audioManager
    )
}

#Preview("Reflection View - No Recording") {
    let audioManager = AudioManager()
    
    ReflectionView(
        currentScreen: .constant(.reflection(nil)),
        recording: nil,
        audioManager: audioManager
    )
}

#Preview("Prompts Sheet") {
    ReflectionPromptsSheet()
}
