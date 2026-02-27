//
//  GroundingView.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/1/26.
//

import SwiftUI

struct GroundingView: View {
    @Binding var currentScreen: AppScreen
    let mode: PracticeMode

    @State private var isBreathingIn = true
    @State private var secondsRemaining = 6
    @State private var breathingTimer: Timer?
    @State private var showSkip = false
    @State private var countdownTimer: Timer?

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: AppTheme.Spacing.xl) {
                topBar
                Spacer()

                // Breathing visualization
                BreathingIndicator(isBreathingIn: isBreathingIn)
                    .frame(width: 240, height: 240)
                    .accessibilityHidden(true)

                breathingCue
                Spacer()
                countdownSection
                skipButton
            }
        }
        .onAppear {
            startTimers()
        }
        .onDisappear {
            cleanupTimers()
        }

        .onChange(of: isBreathingIn) { newValue in
            let announcement = newValue ? "Breathe in" : "Breathe out"
            UIAccessibility.post(
                notification: .announcement,
                argument: announcement
            )
        }
    }
    
    // Top Bar
    private var topBar: some View {
        HStack {
            Button {
                currentScreen = .home
            } label: {
                Image(systemName: "xmark")
                    .font(AppTheme.Fonts.iconFont)
                    .foregroundColor(AppTheme.secondaryText)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Cancel and go home")
            
            Spacer()
            
            Text("Breathe")
                .font(AppTheme.Fonts.secondaryButton)
                .foregroundColor(AppTheme.secondaryText)
            
            Spacer()
            
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.sm)
    }
    
    //  Breathing Cue
    private var breathingCue: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Text(isBreathingIn ? "Breathe in..." : "Breathe out...")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(AppTheme.primaryText)
                .contentTransition(.interpolate)
            
            Text("Relax and center yourself")
                .font(AppTheme.Fonts.screenSubtitle)
                .foregroundColor(AppTheme.tertiaryText)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(isBreathingIn
            ? "Breathing in. Relax and center yourself."
            : "Breathing out. Relax and center yourself.")
    }
    
    // Countdown Section
    private var countdownSection: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Progress dots glow after every second
            HStack(spacing: AppTheme.Spacing.sm) {
                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .fill(index < (6 - secondsRemaining)
                            ? AppTheme.accent
                            : AppTheme.mutedText)
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: secondsRemaining)
                }
            }
            // Countdown text
            Text("Starting in \(secondsRemaining)...")
                .font(AppTheme.Fonts.screenSubtitle)
                .foregroundColor(AppTheme.tertiaryText)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Starting in \(secondsRemaining) seconds")
    }
    
    // Skip Button
    private var skipButton: some View {
        Button {
            currentScreen = .recording(mode)
        } label: {
            Text("Skip")
                .font(AppTheme.Fonts.secondaryButton)
                .foregroundColor(AppTheme.tertiaryText)
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.vertical, AppTheme.Spacing.md)
                .background(AppTheme.cardBackground)
                .cornerRadius(20)
        }
        .buttonStyle(PressableButtonStyle())
        .opacity(showSkip ? 1 : 0)
        .padding(.bottom, AppTheme.Spacing.xxl)
        .accessibilityLabel("Skip breathing exercise")
        .accessibilityHint("Jumps straight to recording")
        .accessibilityHidden(!showSkip)
    }
    
    // - Timer Management
    private func startTimers() {
        // Show skip button after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showSkip = true
            }
        }
        
        // Breathing cycle: 3s inhale / 3s exhale
        breathingTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            Task { @MainActor in
                withAnimation(.easeInOut(duration: 0.3)) {
                    isBreathingIn.toggle()
                }
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            }
        }
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            Task { @MainActor in
                if secondsRemaining > 1 {
                    secondsRemaining -= 1
                } else {
                    cleanupTimers()
                    currentScreen = .recording(mode)
                }
            }
        }
    }
    
    // Resets the timers
    private func cleanupTimers() {
        breathingTimer?.invalidate()
        breathingTimer = nil
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
}

struct BreathingIndicator: View {
    let isBreathingIn: Bool
    
    var body: some View {
        ZStack {
            // Outer rings
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(
                        AppTheme.accent.opacity(0.15 - Double(index) * 0.04),
                        lineWidth: 2
                    )
                    .scaleEffect(isBreathingIn
                        ? 1.0 + CGFloat(index) * 0.15
                        : 0.6 + CGFloat(index) * 0.1)
                    .animation(
                        .easeInOut(duration: 3)
                        .delay(Double(index) * 0.1),
                        value: isBreathingIn
                    )
            }
            
            // Middle glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppTheme.accent.opacity(0.3),
                            AppTheme.accent.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .scaleEffect(isBreathingIn ? 1.1 : 0.7)
                .animation(.easeInOut(duration: 3), value: isBreathingIn)
            
            // Core circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            AppTheme.accent.opacity(0.6),
                            AppTheme.accent.opacity(0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
                .scaleEffect(isBreathingIn ? 1.2 : 0.8)
                .animation(.easeInOut(duration: 3), value: isBreathingIn)
                .shadow(color: AppTheme.accent.opacity(0.5),
                        radius: isBreathingIn ? 30 : 10)
                .animation(.easeInOut(duration: 3), value: isBreathingIn)
        }
    }
}

#Preview("Grounding View") {
    GroundingView(
        currentScreen: .constant(.grounding(.presentation)),
        mode: .presentation
    )
}
