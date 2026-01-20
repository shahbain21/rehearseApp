//
//  NotesView.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/17/26.
//

import SwiftUI

struct NotesView: View {
    @Binding var currentScreen: AppScreen
    @State private var notes: String = ""

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Talking Points")
                .font(.system(size: 24, weight: .semibold))

            Text("These notes are just here to keep you oriented.\nYou don’t need to read them.")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            TextEditor(text: $notes)
                .frame(minHeight: 160)
                .padding(12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

            Button("Start Practice") {
                // We’ll store notes temporarily for now
                NotesStore.shared.currentNotes = notes
                currentScreen = .grounding
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button("Skip") {
                NotesStore.shared.currentNotes = nil
                currentScreen = .grounding
            }
            .font(.system(size: 14))
            .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
    }
}

