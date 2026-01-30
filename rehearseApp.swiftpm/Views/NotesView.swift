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

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Title
            Text(titleText)
                .font(.system(size: 24, weight: .semibold))

            // Guidance
            Text(subtitleText)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            // Import notes button
            Button {
                showingFileImporter = true
            } label: {
                Label("Import notes", systemImage: "doc.text")
            }
            .font(.system(size: 14))
            .foregroundColor(.secondary)

            // Notes editor
            TextEditor(text: $notes)
                .font(.system(size: 15))
                .padding(12)
                .frame(minHeight: 160)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2))
                )

            // Start practice
            Button("Start Practice") {
                NotesStore.shared.currentNotes =
                    notes.trimmingCharacters(in: .whitespacesAndNewlines)
                currentScreen = .grounding(mode)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            // Skip option
            Button("Skip for now") {
                NotesStore.shared.currentNotes = nil
                currentScreen = .grounding(mode)
            }
            .font(.system(size: 14))
            .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
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

    private var titleText: String {
        switch mode {
        case .presentation:
            return "Talking Points"
        case .storytelling:
            return "Story Outline"
        default:
            return "Notes"
        }
    }

    private var subtitleText: String {
        switch mode {
        case .presentation:
            return "Add bullet points or speaker notes.\nThese are just here to keep you oriented."
        case .storytelling:
            return "Add story beats or key moments.\nYou don’t need to read this word‑for‑word."
        default:
            return "Add anything you’d like to reference."
        }
    }
}

#Preview {
    NotesView(
        currentScreen: .constant(.notes(PracticeMode.presentation)),
        mode: PracticeMode.presentation
    )
}
