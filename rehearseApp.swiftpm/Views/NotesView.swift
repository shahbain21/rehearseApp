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

    var body: some View {
        ZStack {
            // Dark background
            Color(red: 0.08, green: 0.08, blue: 0.14)
                .ignoresSafeArea()
                .onTapGesture {
                    isEditorFocused = false
                }

            VStack(spacing: 20) {
                
                // Top bar
                HStack {
                    Button {
                        currentScreen = .home
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Text(modeTitle)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 18, height: 18)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Header
                VStack(spacing: 12) {
                    Text(titleText)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)

                    Text(subtitleText)
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Quick actions
                HStack(spacing: 12) {
                    // Import button
                    QuickActionButton(
                        icon: "doc.text",
                        title: "Import"
                    ) {
                        showingFileImporter = true
                    }
                    
                    // Template button
                    QuickActionButton(
                        icon: "list.bullet.rectangle",
                        title: "Template"
                    ) {
                        withAnimation {
                            notes = templateText
                        }
                    }
                    
                    // Clear button
                    QuickActionButton(
                        icon: "trash",
                        title: "Clear"
                    ) {
                        withAnimation {
                            notes = ""
                        }
                    }
                    .opacity(notes.isEmpty ? 0.5 : 1)
                    .disabled(notes.isEmpty)
                }
                .padding(.horizontal)

                // Notes editor
                VStack(alignment: .leading, spacing: 8) {
                    ZStack(alignment: .topLeading) {
                        if notes.isEmpty {
                            Text(placeholderText)
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.3))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                        }
                        
                        TextEditor(text: $notes)
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .focused($isEditorFocused)
                    }
                    .frame(minHeight: 180)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isEditorFocused
                                    ? Color.blue.opacity(0.5)
                                    : Color.white.opacity(0.1),
                                lineWidth: 1
                            )
                    )
                    
                    // Character count
                    HStack {
                        if !notes.isEmpty {
                            let lineCount = notes.components(separatedBy: "\n").filter { !$0.isEmpty }.count
                            Text("\(lineCount) lines")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.3))
                        }
                        
                        Spacer()
                        
                        Text("\(notes.count) characters")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.3))
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Action buttons
                VStack(spacing: 12) {
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
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.blue)
                        )
                    }

                    Button {
                        NotesStore.shared.currentNotes = nil
                        currentScreen = .grounding(mode)
                    } label: {
                        Text("Skip for now")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
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
    }

    // MARK: - Copy helpers

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

// MARK: - Quick Action Button

struct QuickActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                Text(title)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(.white.opacity(0.7))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.08))
            .cornerRadius(12)
        }
    }
}

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
