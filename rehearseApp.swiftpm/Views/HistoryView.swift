//
//  HistoryView.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/5/26.
//

import SwiftUI

struct HistoryView: View {
    @Binding var currentScreen: AppScreen
    @ObservedObject var audioManager: AudioManager
    
    @State private var selectedFilter: ModeFilter = .all

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                if audioManager.recordings.isEmpty {
                    EmptyHistoryView {
                        currentScreen = .home
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: AppTheme.Spacing.xl) {
                            statsSummary
                            filterBar
                            recordingsList
                        }
                        .padding(.bottom, AppTheme.Spacing.xl)
                    }
                }
            }
        }
        .onDisappear {
            audioManager.stopPlayback()
        }
    }
    
    // Top Bar
    private var topBar: some View {
        HStack {
            Button {
                currentScreen = .home
            } label: {
                Image(systemName: "chevron.left")
                    .font(AppTheme.Fonts.iconFont)
                    .foregroundColor(AppTheme.secondaryText)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Back to home")
            
            Spacer()
            
            Text("History")
                .font(AppTheme.Fonts.navTitle)
                .foregroundColor(AppTheme.primaryText)
            
            Spacer()
            
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.vertical, AppTheme.Spacing.lg)
    }
    
    //  Shows practice habits at a glance
    
    private var statsSummary: some View {
        HStack(spacing: AppTheme.Spacing.lg) {
            // Get total sessions from audio manager
            StatBadge(
                value: "\(audioManager.recordings.count)",
                label: "Sessions"
            )
            //
            StatBadge(
                value: totalPracticeTime,
                label: "Total Time"
            )
            
            StatBadge(
                value: "\(practiceStreak)",
                label: "Day Streak",
            )
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.Radius.card)
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
    
    // Filter recordings by practice mode
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(ModeFilter.allCases, id: \.self) { filter in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedFilter = filter
                        }
                    } label: {
                        Text(filter.label)
                            .font(AppTheme.Fonts.smallLabel)
                            .foregroundColor(selectedFilter == filter
                                             ? AppTheme.primaryText
                                             : AppTheme.tertiaryText)
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .padding(.vertical, AppTheme.Spacing.sm)
                            .background(
                                Capsule()
                                    .fill(selectedFilter == filter
                                          ? AppTheme.accent
                                          : AppTheme.cardBackground)
                            )
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
        }
    }
    
    // Recordings List
    
    private var recordingsList: some View {
        let grouped = groupedRecordings
        
        return VStack(spacing: AppTheme.Spacing.xl) {
            ForEach(grouped, id: \.title) { group in
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    // Section header
                    Text(group.title.uppercased())
                        .font(AppTheme.Fonts.smallLabel)
                        .foregroundColor(AppTheme.tertiaryText)
                        .tracking(0.8)
                        .padding(.horizontal, AppTheme.Spacing.lg)
                    
                    // Rows
                    LazyVStack(spacing: AppTheme.Spacing.md) {
                        ForEach(group.recordings) { recording in
                            RecordingRow(
                                recording: recording,
                                isPlaying: audioManager.currentlyPlayingID == recording.id,
                                onPlay: { audioManager.togglePlayback(for: recording) },
                                onViewFeedback: { currentScreen = .feedback(recording) },
                                onDelete: { audioManager.deleteRecording(recording) }
                            )
                            // Swipe actions for easier interaction
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        audioManager.deleteRecording(recording)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    currentScreen = .feedback(recording)
                                } label: {
                                    Label("Feedback", systemImage: "chart.bar")
                                }
                                .tint(AppTheme.accent)
                            }
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                }
            }
        }
    }
    

    
    // Filter recordings based on selected mode
    private var filteredRecordings: [Recording] {
        switch selectedFilter {
        case .all:
            return audioManager.recordings
        case .interview:
            return audioManager.recordings.filter { $0.mode == .interview }
        case .presentation:
            return audioManager.recordings.filter { $0.mode == .presentation }
        case .storytelling:
            return audioManager.recordings.filter { $0.mode == .storytelling }
        case .free:
            return audioManager.recordings.filter { $0.mode == .free }
        }
    }
    
    // Groups recordings based of when they recorded them
    private var groupedRecordings: [RecordingGroup] {
        let calendar = Calendar.current
        var groups: [String: [Recording]] = [:]
        let order = ["Today", "Yesterday", "This Week", "Earlier"]
        
        // Checks when it was recorded and then groups them
        for recording in filteredRecordings {
            let key: String
            if calendar.isDateInToday(recording.date) {
                key = "Today"
            } else if calendar.isDateInYesterday(recording.date) {
                key = "Yesterday"
            } else if let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()),
                      recording.date > weekAgo {
                key = "This Week"
            } else {
                key = "Earlier"
            }
            
            groups[key, default: []].append(recording)
        }
        
        return order.compactMap { title in
            guard let recordings = groups[title], !recordings.isEmpty else { return nil }
            return RecordingGroup(title: title, recordings: recordings)
        }
    }
    
    // Calculates total practice time
    private var totalPracticeTime: String {
        let total = audioManager.recordings.reduce(0) { $0 + $1.duration }
        let totalMinutes = Int(total) / 60
        let seconds = Int(total) % 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
    
    // Finds streak of recordings
    private var practiceStreak: Int {
        let calendar = Calendar.current
        let dates = Set(audioManager.recordings.map {
            calendar.startOfDay(for: $0.date)
        })
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        
        // Starts from yesterday if you haven't recorded yet that day
        if !dates.contains(checkDate) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                return 0
            }
            checkDate = yesterday
        }
        // Count consecutive days backwards
        while dates.contains(checkDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                break
            }
            checkDate = previousDay
        }
        return streak
    }
}

// Groups recordings under a date section header
struct RecordingGroup {
    let title: String
    let recordings: [Recording]
}

// Filter options for the mode filter bar
enum ModeFilter: CaseIterable {
    case all
    case interview
    case presentation
    case storytelling
    case free
    
    var label: String {
        switch self {
        case .all:          return "All"
        case .interview:    return "Interview"
        case .presentation: return "Presentation"
        case .storytelling: return "Storytelling"
        case .free:         return "Free"
        }
    }
}

// Small stat display for the summary card
struct StatBadge: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            HStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppTheme.primaryText)
            }
            
            Text(label)
                .font(AppTheme.Fonts.smallLabel)
                .foregroundColor(AppTheme.tertiaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

// Button to start first session if recording is empty
struct EmptyHistoryView: View {
    let onStartSession: () -> Void
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(AppTheme.cardBackground)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "waveform")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(AppTheme.mutedText)
            }
            
            Text("No recordings yet")
                .font(AppTheme.Fonts.screenTitle)
                .foregroundColor(AppTheme.primaryText)
            
            Text("Your practice sessions will appear here")
                .font(AppTheme.Fonts.screenSubtitle)
                .foregroundColor(AppTheme.tertiaryText)
                .multilineTextAlignment(.center)
            
            Button(action: onStartSession) {
                HStack {
                    Text("Start your first session")
                    Image(systemName: "arrow.right")
                }
                .font(AppTheme.Fonts.buttonLabel)
                .foregroundColor(AppTheme.primaryText)
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.vertical, AppTheme.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.Radius.button)
                        .fill(AppTheme.accent)
                )
            }
            .padding(.top, AppTheme.Spacing.md)
            
            Spacer()
        }
        .padding(AppTheme.Spacing.lg)
    }
}


struct RecordingRow: View {
    let recording: Recording
    let isPlaying: Bool
    let onPlay: () -> Void
    let onViewFeedback: () -> Void
    let onDelete: () -> Void
    
    @State private var showDeleteConfirmation = false
    
    private var score: Int {
        FeedbackGenerator.generate(from: recording).overallScore
    }

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            playButton
            recordingInfo
            Spacer()
            scoreBadge
            HStack(spacing: AppTheme.Spacing.sm) {
                Button {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.mutedText)
                        .frame(width: 30, height: 30)
                        .background(AppTheme.cardBackground)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Delete recording")
                
                Button(action: onViewFeedback) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.tertiaryText)
                        .frame(width: 30, height: 30)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("View feedback")
            }
        }
        .padding(AppTheme.Spacing.md)
        .background(cardBackground)
        .confirmationDialog(
            "Delete Recording",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                withAnimation {
                    onDelete()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    
    private var playButton: some View {
        Button(action: onPlay) {
            ZStack {
                Circle()
                    .fill(isPlaying
                          ? AppTheme.destructive.opacity(0.15)
                          : AppTheme.accentMuted)
                    .frame(width: 44, height: 44)
                
                if isPlaying {
                    Circle()
                        .stroke(AppTheme.destructive.opacity(0.3), lineWidth: 2)
                        .frame(width: 44, height: 44)
                    
                    SpinningRing()
                        .frame(width: 44, height: 44)
                }
                
                Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isPlaying ? AppTheme.destructive : AppTheme.accent)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isPlaying ? "Stop playback" : "Play recording")
    }
    
    private var recordingInfo: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            HStack(spacing: AppTheme.Spacing.sm) {
                // Date of recording
                Text(formatDate(recording.date))
                    .font(AppTheme.Fonts.cardTitle)
                    .foregroundColor(AppTheme.primaryText)
                    .lineLimit(1)
                
                if isPlaying {
                    PlayingIndicator()
                }
            }
            // Display the mode
            HStack(spacing: AppTheme.Spacing.sm) {
                if let mode = recording.mode {
                    Text(mode.shortName)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppTheme.accent)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(AppTheme.accentMuted)
                        .cornerRadius(4)
                }
                // Audio length
                HStack(spacing: 2) {
                    Image(systemName: "clock")
                        .font(.system(size: 9))
                    Text(formatDuration(recording.duration))
                        .font(.system(size: 11))
                }
                .foregroundColor(AppTheme.tertiaryText)
                // Number of pauses
                HStack(spacing: 2) {
                    Image(systemName: "pause.circle")
                        .font(.system(size: 9))
                    Text("\(recording.pauses.count)")
                        .font(.system(size: 11))
                }
                .foregroundColor(AppTheme.tertiaryText)
            }
            // Whether the recording has notes/ a reflection
            HStack(spacing: AppTheme.Spacing.sm) {
                if let notes = recording.notes, !notes.isEmpty {
                    HStack(spacing: 2) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 9))
                        Text("Notes")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(AppTheme.mutedText)
                }
                
                if recording.reflection != nil {
                    HStack(spacing: 2) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 9))
                        Text("Reflected")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(AppTheme.accent.opacity(0.5))
                }
            }
        }
    }
    
    private var scoreBadge: some View {
        ZStack {
            Circle()
                .stroke(AppTheme.border, lineWidth: 2.5)
                .frame(width: 34, height: 34)
            
            Circle()
                .trim(from: 0, to: CGFloat(score) / 100)
                .stroke(
                    scoreColor,
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                )
                .frame(width: 34, height: 34)
                .rotationEffect(.degrees(-90))
            
            Text("\(score)")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(AppTheme.primaryText)
        }
        .accessibilityLabel("Score: \(score) out of 100")
    }
    
    private var scoreColor: Color {
        switch score {
        case 80...100: return .green
        case 65..<80:  return .cyan
        case 50..<65:  return .yellow
        default:       return .orange
        }
    }
        
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: AppTheme.Radius.card)
            .fill(AppTheme.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                    .stroke(
                        isPlaying
                            ? AppTheme.destructive.opacity(0.3)
                            : AppTheme.border,
                        lineWidth: 1
                    )
            )
    }
    
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today, " + date.formatted(date: .omitted, time: .shortened)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return date.formatted(.dateTime.month(.abbreviated).day())
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}

// Spinning Ring animation when clicked
struct SpinningRing: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.3)
            .stroke(AppTheme.destructive, lineWidth: 2)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

// Animated bars while audio plays
struct PlayingIndicator: View {
    @State private var animating = false
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .fill(AppTheme.destructive)
                    .frame(width: 2, height: animating ? 10 : 4)
                    .animation(
                        .easeInOut(duration: 0.4)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.15),
                        value: animating
                    )
            }
        }
        .onAppear { animating = true }
    }
}

#Preview("History View") {
    let audioManager = AudioManager()

    let _ = {
        audioManager.recordings = [
            Recording(
                id: UUID(),
                url: URL(fileURLWithPath: "/dev/null"),
                date: Date(),
                duration: 125.2,
                speakingTime: 98.1,
                pauses: [0.5, 1.2, 0.8],
                notes: "My presentation notes",
                mode: .presentation
            ),
            Recording(
                id: UUID(),
                url: URL(fileURLWithPath: "/dev/null"),
                date: Date().addingTimeInterval(-3600),
                duration: 65.0,
                speakingTime: 45.2,
                pauses: [0.8, 1.2, 2.5],
                notes: nil,
                mode: .interview
            ),
            Recording(
                id: UUID(),
                url: URL(fileURLWithPath: "/dev/null"),
                date: Date().addingTimeInterval(-86400),
                duration: 32.5,
                speakingTime: 22.4,
                pauses: [0.8, 1.2],
                notes: nil,
                mode: .interview
            ),
            Recording(
                id: UUID(),
                url: URL(fileURLWithPath: "/dev/null"),
                date: Date().addingTimeInterval(-172800),
                duration: 245.0,
                speakingTime: 180.5,
                pauses: [0.3, 0.5, 0.8, 1.1, 2.3],
                notes: "Interview practice",
                mode: .free
            ),
            Recording(
                id: UUID(),
                url: URL(fileURLWithPath: "/dev/null"),
                date: Date().addingTimeInterval(-604800),
                duration: 180.0,
                speakingTime: 120.0,
                pauses: [0.4, 0.6, 0.9],
                notes: "Storytelling session",
                mode: .storytelling
            )
        ]
    }()

    HistoryView(
        currentScreen: .constant(.history),
        audioManager: audioManager
    )
}

#Preview("History View - Empty") {
    let audioManager = AudioManager()
    
    HistoryView(
        currentScreen: .constant(.history),
        audioManager: audioManager
    )
}
