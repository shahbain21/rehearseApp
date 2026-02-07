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

    private let countdownTimer =
        Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Dark background
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 32) {
                
                // X symbol
                HStack {
                    Button {
                        currentScreen = .home
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Text("Breathe")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    // Invisible placeholder for symmetry
                    Color.clear
                        .frame(width: 18, height: 18)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                Spacer()

                // Breathing visualization
                BreathingIndicator(isBreathingIn: isBreathingIn)
                    .frame(width: 240, height: 240)

                // Breathing cue
                VStack(spacing: 8) {
                    Text(isBreathingIn ? "Breathe in..." : "Breathe out...")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text("Relax and center yourself")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.5))
                }

                Spacer()

                // Countdown indicator
                VStack(spacing: 16) {
                    // Progress dots
                    HStack(spacing: 8) {
                        ForEach(0..<6, id: \.self) { index in
                            Circle()
                                .fill(index < (6 - secondsRemaining)
                                    ? Color.blue
                                    : Color.white.opacity(0.2))
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut(duration: 0.3), value: secondsRemaining)
                        }
                    }
                    
                    Text("Starting in \(secondsRemaining)...")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.5))
                }

                // Skip button
                Button {
                    currentScreen = .recording(mode)
                } label: {
                    Text("Skip")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                }
                .opacity(showSkip ? 1 : 0)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            // Show skip button after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showSkip = true
                }
            }
            
            // Start breathing cycle: 3s inhale / 3s exhale
            breathingTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                Task { @MainActor in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isBreathingIn.toggle()
                    }
                }
            }
        }
        .onDisappear {
            breathingTimer?.invalidate()
            breathingTimer = nil
        }
        .onReceive(countdownTimer) { _ in
            if secondsRemaining > 1 {
                secondsRemaining -= 1
            } else {
                currentScreen = .recording(mode)
            }
        }
    }
}

// MARK: - Breathing Indicator

struct BreathingIndicator: View {
    let isBreathingIn: Bool
    
    var body: some View {
        ZStack {
            // Outer rings
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(
                        Color.blue.opacity(0.15 - Double(index) * 0.04),
                        lineWidth: 2
                    )
                    .scaleEffect(isBreathingIn ? 1.0 + CGFloat(index) * 0.15 : 0.6 + CGFloat(index) * 0.1)
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
                            Color.blue.opacity(0.3),
                            Color.blue.opacity(0.1),
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
                            Color.blue.opacity(0.6),
                            Color.blue.opacity(0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
                .scaleEffect(isBreathingIn ? 1.2 : 0.8)
                .animation(.easeInOut(duration: 3), value: isBreathingIn)
                .shadow(color: Color.blue.opacity(0.5), radius: isBreathingIn ? 30 : 10)
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
