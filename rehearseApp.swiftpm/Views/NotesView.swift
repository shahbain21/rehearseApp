//
//  NotesView.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/1/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct NotesView: View {
    @Binding var currentScreen: AppScreen
    let mode: PracticeMode

    @State private var notes: String = ""
    @State private var showingFileImporter = false
    @FocusState private var isEditorFocused: Bool
    
    // Controls confirmation dialogs
    @State private var showTemplateConfirmation = false
    @State private var showClearConfirmation = false
    @State private var showBackConfirmation = false

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
                .onTapGesture {
                    isEditorFocused = false
                }

            VStack(spacing: AppTheme.Spacing.xl) {
                topBar
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppTheme.Spacing.xl) {
                        headerSection
                        quickActions
                        notesEditor
                    }
                }
                
                actionButtons
            }
        }
        .fileImporter(
            isPresented: $showingFileImporter,
            allowedContentTypes: [.plainText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }

                let didStartAccessing = url.startAccessingSecurityScopedResource()
                defer {
                    if didStartAccessing {
                        url.stopAccessingSecurityScopedResource()
                    }
                }

                do {
                    let text = try String(contentsOf: url, encoding: .utf8)
                    notes = text
                } catch {
                    print("Failed to read file:", error)
                }

            case .failure(let error):
                print("Import failed:", error)
            }
        }
        // Confirmation before template overwrites existing notes
        .confirmationDialog(
            "Replace Notes",
            isPresented: $showTemplateConfirmation,
            titleVisibility: .visible
        ) {
            Button("Replace with Template", role: .destructive) {
                withAnimation {
                    notes = templateText
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your current notes will be replaced with the template.")
        }
        // Confirmation before clearing notes
        .confirmationDialog(
            "Clear Notes",
            isPresented: $showClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("Clear All", role: .destructive) {
                withAnimation {
                    notes = ""
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will delete everything you've written.")
        }
        // Warning when going back with unsaved notes
        .confirmationDialog(
            "Discard Notes?",
            isPresented: $showBackConfirmation,
            titleVisibility: .visible
        ) {
            Button("Discard", role: .destructive) {
                currentScreen = .home
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You have unsaved notes. Going back will discard them.")
        }
    }
    
    // Top Bar
    private var topBar: some View {
        HStack {
            Button {
                // If user has typed notes, show a warning before going back
                if notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    currentScreen = .home
                } else {
                    showBackConfirmation = true
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(AppTheme.Fonts.iconFont)
                    .foregroundColor(AppTheme.secondaryText)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Go back")
            Spacer()
            Text(modeTitle)
                .font(AppTheme.Fonts.secondaryButton)
                .foregroundColor(AppTheme.secondaryText)
            Spacer()
            Color.clear
                .frame(width: 18, height: 18)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.sm)
    }
    
    // Header
    private var headerSection: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Text(titleText)
                .font(AppTheme.Fonts.screenTitle)
                .foregroundColor(AppTheme.primaryText)

            Text(subtitleText)
                .font(AppTheme.Fonts.screenSubtitle)
                .foregroundColor(AppTheme.tertiaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.lg)
        }
    }
    
    // Quick Actions
    private var quickActions: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Import button
            QuickActionButton(
                icon: "doc.text",
                title: "Import"
            ) {
                showingFileImporter = true
            }
            
            // Template button — now confirms before overwriting
            QuickActionButton(
                icon: "list.bullet.rectangle",
                title: "Template"
            ) {
                if notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    withAnimation {
                        notes = templateText
                    }
                } else {
                    showTemplateConfirmation = true
                }
            }
            
            // Clear button — now confirms before clearing
            QuickActionButton(
                icon: "trash",
                title: "Clear"
            ) {
                showClearConfirmation = true
            }
            .opacity(notes.isEmpty ? 0.5 : 1)
            .disabled(notes.isEmpty)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
    
    // Notes Editor
    private var notesEditor: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            ZStack(alignment: .topLeading) {
                if notes.isEmpty {
                    Text(placeholderText)
                        .font(AppTheme.Fonts.screenSubtitle)
                        .foregroundColor(AppTheme.mutedText)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                        .padding(.vertical, 14)
                }
                
                TextEditor(text: $notes)
                    .font(AppTheme.Fonts.screenSubtitle)
                    .foregroundColor(AppTheme.primaryText)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .focused($isEditorFocused)
            }
            .frame(minHeight: 180, maxHeight: .infinity)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.Radius.card)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                    .stroke(
                        isEditorFocused
                            ? AppTheme.borderSelected
                            : AppTheme.border,
                        lineWidth: 1
                    )
            )
            
            statsRow
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
    
    // Shows the word/char count
    private var statsRow: some View {
        HStack {
            if !notes.isEmpty {
//                let lineCount = notes.components(separatedBy: "\n")
//                    .filter { !$0.isEmpty }.count
                
//                // Line Count
//                Text("\(lineCount) lines")
//                    .font(AppTheme.Fonts.smallLabel)
//                    .foregroundColor(AppTheme.mutedText)
                
                // Dot separator
                Text("·")
                    .font(AppTheme.Fonts.smallLabel)
                    .foregroundColor(AppTheme.mutedText)
                
                // Word count
                Text("\(wordCount) words")
                    .font(AppTheme.Fonts.smallLabel)
                    .foregroundColor(AppTheme.mutedText)
                
//                // Estimated speaking time
//                if wordCount >= 10 {
//                    Text("·")
//                        .font(AppTheme.Fonts.smallLabel)
//                        .foregroundColor(AppTheme.mutedText)
//                    
//                    Text("~\(estimatedSpeakingTime)")
//                        .font(AppTheme.Fonts.smallLabel)
//                        .foregroundColor(AppTheme.accent.opacity(0.6))
//                }
            }
            
            Spacer()
            
            Text("\(notes.count) characters")
                .font(AppTheme.Fonts.smallLabel)
                .foregroundColor(AppTheme.mutedText)
        }
    }
    
    // Action Buttons
    private var actionButtons: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Button {
                isEditorFocused = false
                NotesStore.shared.currentNotes =
                    notes.trimmingCharacters(in: .whitespacesAndNewlines)
                currentScreen = .grounding(mode)
            } label: {
                HStack {
                    Text("Start Practice")
                    Image(systemName: "arrow.right")
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
            .accessibilityHint("Starts your practice session with the notes you've written")

            Button {
                NotesStore.shared.currentNotes = nil
                currentScreen = .grounding(mode)
            } label: {
                Text("Skip for now")
                    .font(AppTheme.Fonts.secondaryButton)
                    .foregroundColor(AppTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppTheme.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.button)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
            }
            .accessibilityHint("Starts your session without any notes")
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
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

    
    // Word count for the stats row
    private var wordCount: Int {
        notes.split(separator: " ").count
    }
    
//    // Estimated speaking time based on ~130 words per minute
//    private var estimatedSpeakingTime: String {
//        let minutes = Double(wordCount) / 130.0
//        if minutes < 1 {
//            let seconds = Int(minutes * 60)
//            return "\(seconds)s speaking"
//        } else {
//            let mins = Int(minutes)
//            let secs = Int((minutes - Double(mins)) * 60)
//            if secs == 0 {
//                return "\(mins)m speaking"
//            } else {
//                return "\(mins)m \(secs)s speaking"
//            }
//        }
//    }

    // Helpers

    private var modeTitle: String {
        switch mode {
        case .interview:
            return "Interview Prep"
        case .presentation:
            return "Presentation Prep"
        case .storytelling:
            return "Story Prep"
        case .free:
            return "Notes"
        }
    }

    private var titleText: String {
        switch mode {
        case .presentation:
            return "Talking Points"
        case .storytelling:
            return "Story Outline"
        case .interview:
            return "Key Points"
        default:
            return "Notes"
        }
    }

    private var subtitleText: String {
        switch mode {
        case .presentation:
            return "Add bullet points or speaker notes.\nThese will appear during your practice."
        case .storytelling:
            return "Add story beats or key moments.\nYou don't need to read this word-for-word."
        case .interview:
            return "Add key points you want to remember.\nThese are just here to keep you oriented."
        default:
            return "Add anything you'd like to reference."
        }
    }
    
    private var placeholderText: String {
        switch mode {
        case .presentation:
            return "• Introduction\n• Main point 1\n• Main point 2\n• Conclusion..."
        case .storytelling:
            return "• Opening hook\n• Rising action\n• Climax\n• Resolution..."
        case .interview:
            return "• My key strengths\n• Relevant experience\n• Questions to ask..."
        default:
            return "Enter your notes here..."
        }
    }
    
    private var templateText: String {
        switch mode {
        case .presentation:
            return """
            Introduction
            - Hook / attention grabber
            - Overview of what you'll cover

            Main Point 1
            - Supporting detail
            - Example or data

            Main Point 2
            - Supporting detail
            - Example or data

            Main Point 3
            - Supporting detail
            - Example or data

            Conclusion
            - Summary of key points
            - Call to action
            """
        case .storytelling:
            return """
            Opening Hook
            - Set the scene
            - Introduce the character

            Rising Action
            - The challenge or problem
            - Building tension

            Climax
            - The turning point
            - Key moment of change

            Resolution
            - How things resolved
            - Lesson learned
            """
        case .interview:
            return """
            About Me
            - Brief background
            - Current role/situation

            Key Strengths
            - Strength 1 + example
            - Strength 2 + example

            Relevant Experience
            - Achievement 1
            - Achievement 2

            Why This Role
            - What excites you
            - How you can contribute

            Questions to Ask
            - About the team
            - About growth opportunities
            """
        default:
            return ""
        }
    }
}

// Quick Action Button

struct QuickActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(AppTheme.Fonts.iconFont)
                Text(title)
                    .font(AppTheme.Fonts.smallLabel)
            }
            .foregroundColor(AppTheme.secondaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.md)
            .background(AppTheme.cardBackground)
            .cornerRadius(AppTheme.Radius.card)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

// Previews

#Preview("Notes View") {
    NotesView(
        currentScreen: .constant(.notes(.presentation)),
        mode: .presentation
    )
}

#Preview("Notes View - Interview") {
    NotesView(
        currentScreen: .constant(.notes(.interview)),
        mode: .interview
    )
}
