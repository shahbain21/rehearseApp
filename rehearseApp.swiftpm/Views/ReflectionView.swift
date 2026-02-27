//
//  ReflectionView.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/1/26.
//

import SwiftUI

// Struct for reflections
struct Reflection: Codable {
    let mood: String
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
    
    // Used to hide keyboard
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
                        noteSection
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
            // Transition to history page
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
            
            // Provides some questions to reflect over
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
    
    // Provides a quick summary of the performance
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
            return "Strong session"
        } else if ratio > 0.5 {
            return "Solid practice"
        } else {
            return "Good effort"
        }
    }
    
    // Generate subtitle from actual metrics
    private var performanceSubtitle: String {
        guard let recording = recording else {
            return "A few words is enough.\nThis helps you grow faster."
        }
        
        let speakingPercent = Int(recording.speakingRatio * 100)
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
    
    // Buttons for completing reflection
    private var actionButtons: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Button if you're finished
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
            
            // Button if you want to skip
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
        
    // Saves reflection data to the recording
    private func saveReflection() {
        let reflection = Reflection(
            mood: selectedMood?.label ?? "None",
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
    
    var symbol: String {
        switch self {
        case .great: return "flame.fill"
        case .good:  return "hand.thumbsup.fill"
        case .okay:  return "minus.circle.fill"
        case .rough: return "exclamationmark.triangle.fill"
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
                Image(systemName: mood.symbol)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(isSelected ? mood.color : AppTheme.tertiaryText)

                
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
