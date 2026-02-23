//
//  RecordingView.swift
//  rehearseApp
//
//  Option A: Swipeable Cards
//
//  Created by Mohamed Shahbain on 1/1/26.
//

import SwiftUI

struct RecordingView: View {

    @Binding var currentScreen: AppScreen
    @ObservedObject var audioManager: AudioManager
    let mode: PracticeMode

    @State private var currentSlideIndex = 0
    @State private var showNotes = false
    @State private var showLeaveConfirmation = false

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            VStack(spacing: AppTheme.Spacing.xl) {
                topBar
                Spacer()
                
                // Notes overlay
                if showNotes && !noteSlides.isEmpty {
                    notesCardView
                }
                Spacer()

                // Waveform visualization
                MirroredWaveformView(
                    audioLevel: audioManager.currentAudioLevel,
                    barCount: 60,
                    isRecording: audioManager.isRecording
                )
                .frame(height: 120)
                .padding(.horizontal, AppTheme.Spacing.lg)
                Spacer()

                // Timer
                timerDisplay
                Spacer()

                // Controls
                controlBar
            }
        }
        .onAppear {
            audioManager.elapsedTime = 0
            audioManager.speakingTime = 0
            audioManager.currentAudioLevel = 0.0
        }
        .confirmationDialog(
            "Stop Recording?",
            isPresented: $showLeaveConfirmation,
            titleVisibility: .visible
        ) {
            Button("Stop & Discard", role: .destructive) {
                audioManager.discardRecording() 
                currentScreen = .home
            }
            Button("Stop & Save") {
                audioManager.stopRecording()
                if let latest = audioManager.recordings.first {
                    currentScreen = .feedback(latest)
                } else {
                    currentScreen = .home
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You're currently recording. Leaving will discard this session.")
        }
    }
    
    private var topBar: some View {
        HStack {
            Button {
                if audioManager.isRecording {
                    showLeaveConfirmation = true
                } else {
                    currentScreen = .home
                }
            } label: {
                Image(systemName: "xmark")
                    .font(AppTheme.Fonts.iconFont)
                    .foregroundColor(AppTheme.secondaryText)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Leave recording")
            
            Spacer()
            
            Text(modeTitle)
                .font(AppTheme.Fonts.smallLabel)
                .foregroundColor(AppTheme.secondaryText)
            
            Spacer()
            
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.sm)
    }
    
    // Presents notes in a card view
    private var notesCardView: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            TabView(selection: $currentSlideIndex) {
                ForEach(Array(noteSlides.enumerated()), id: \.offset) { index, slide in
                    noteCard(slide)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 160)
            
            // Progress indicator
            notesProgress
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    // Individual note card
    private func noteCard(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            let lines = text.components(separatedBy: "\n")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            
            if let title = lines.first {
                Text(cleanLine(title))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(AppTheme.primaryText)
            }
            
            if lines.count > 1 {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    ForEach(Array(lines.dropFirst().enumerated()), id: \.offset) { _, line in
                        Text(cleanLine(line))
                            .font(AppTheme.Fonts.cardSubtitle)
                            .foregroundColor(AppTheme.secondaryText)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                .fill(AppTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
        )
        .padding(.horizontal, AppTheme.Spacing.xs)
    }
    
    // Progress dots + slide counter
    private var notesProgress: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            if noteSlides.count <= 10 {
                HStack(spacing: 6) {
                    ForEach(0..<noteSlides.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentSlideIndex
                                  ? AppTheme.accent
                                  : AppTheme.mutedText)
                            .frame(width: 6, height: 6)
                            .animation(.easeInOut(duration: 0.2), value: currentSlideIndex)
                    }
                }
            }
            
            Spacer()
            
            Text("\(currentSlideIndex + 1) / \(noteSlides.count)")
                .font(AppTheme.Fonts.smallLabel)
                .foregroundColor(AppTheme.tertiaryText)
        }
    }
    
    // Timer Display
    private var timerDisplay: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Text(formatTime(audioManager.elapsedTime))
                .font(.system(size: 64, weight: .light, design: .rounded))
                .foregroundColor(AppTheme.primaryText)
                .monospacedDigit()

            Text(statusText)
                .font(AppTheme.Fonts.secondaryButton)
                .foregroundColor(AppTheme.tertiaryText)
        }
    }
    
    // Control Bar
    private var controlBar: some View {
        HStack(spacing: 60) {
            // History button
            Button {
                if audioManager.isRecording {
                    audioManager.stopRecording()
                }
                withAnimation {
                    currentScreen = .history
                }
            } label: {
                VStack(spacing: 6) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 22))
                    Text("History")
                        .font(AppTheme.Fonts.smallLabel)
                }
                .foregroundColor(AppTheme.secondaryText)
                .frame(width: 60, height: 60)
                .contentShape(Rectangle())
            }
            .accessibilityLabel("View history")

            // Record / Stop Button
            Button {
                toggleRecording()
            } label: {
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(AppTheme.mutedText, lineWidth: 4)
                        .frame(width: 80, height: 80)
                    
                    if audioManager.isRecording {
                        // Stop button (rounded square)
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppTheme.destructive)
                            .frame(width: 32, height: 32)
                    } else {
                        // Record button (circle)
                        Circle()
                            .fill(AppTheme.destructive)
                            .frame(width: 64, height: 64)
                    }
                }
            }
            .accessibilityLabel(audioManager.isRecording ? "Stop recording" : "Start recording")
            
            // Notes Button
            if !noteSlides.isEmpty {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showNotes.toggle()
                    }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: showNotes ? "doc.text.fill" : "doc.text")
                            .font(.system(size: 22))
                        Text("Notes")
                            .font(AppTheme.Fonts.smallLabel)
                    }
                    .foregroundColor(showNotes ? AppTheme.accent : AppTheme.secondaryText)
                    .frame(width: 60, height: 60)
                    .contentShape(Rectangle())
                }
                .accessibilityLabel(showNotes ? "Hide notes" : "Show notes")
            } else {
                Color.clear
                    .frame(width: 60, height: 60)
            }
        }
        .padding(.bottom, AppTheme.Spacing.xxl)
    }

    // Computed Properties

    // Split up by new line separators
    private var noteSlides: [String] {
        guard let notes = NotesStore.shared.currentNotes else { return [] }
        
        return notes
            .components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    // Strips leading "- " or "• " for cleaner card text
    private func cleanLine(_ line: String) -> String {
        var cleaned = line.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let prefixes = ["- ", "• ", "* "]
        for prefix in prefixes {
            if cleaned.hasPrefix(prefix) {
                cleaned = "• " + cleaned.dropFirst(prefix.count)
                break
            }
        }
        
        return cleaned
    }

    private var modeTitle: String {
        switch mode {
        case .interview:    return "Interview Practice"
        case .presentation: return "Presentation Practice"
        case .storytelling: return "Storytelling Practice"
        case .free:         return "Free Practice"
        }
    }
    
    private var statusText: String {
        if audioManager.isRecording {
            return "Recording..."
        } else if audioManager.elapsedTime > 0 {
            return "Paused"
        } else {
            return "Tap to record"
        }
    }

    // Actions
    private func toggleRecording() {
        if audioManager.isRecording {
            audioManager.stopRecording()
            UINotificationFeedbackGenerator().notificationOccurred(.success)

            if let latest = audioManager.recordings.first {
                withAnimation {
                    currentScreen = .feedback(latest)
                }
            }
        } else {
            currentSlideIndex = 0
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            audioManager.startRecording()
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview("Recording View - Cards") {
    let audioManager = AudioManager()

    let _ = {
        NotesStore.shared.currentNotes = """
        Introduction
        - Hook / attention grabber
        - Overview of what you'll cover

        Main Point 1
        - Supporting detail
        - Example or data

        Main Point 2
        - Supporting detail
        - Example or data

        Conclusion
        - Summary of key points
        - Call to action
        """
    }()

    RecordingView(
        currentScreen: .constant(.recording(.presentation)),
        audioManager: audioManager,
        mode: .presentation
    )
}

#Preview("Recording - No Notes") {
    let audioManager = AudioManager()
    
    RecordingView(
        currentScreen: .constant(.recording(.free)),
        audioManager: audioManager,
        mode: .free
    )
}
