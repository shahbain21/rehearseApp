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

    private let countdownTimer =
        Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Breathing circle
            Circle()
                .fill(Color.blue.opacity(0.15))
                .frame(width: 200, height: 200)
                .scaleEffect(isBreathingIn ? 1.2 : 0.8)
                .animation(
                    .easeInOut(duration: 3),
                    value: isBreathingIn
                )
                .padding(25)

            // Breathing cue
            Text(isBreathingIn ? "Inhale" : "Exhale")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(.secondary)

            // Countdown
            Text("Starting in \(secondsRemaining)…")
                .font(.system(size: 22))
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
        .onAppear {
            // Start breathing cycle: 3s inhale / 3s exhale
            breathingTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                Task { @MainActor in
                    isBreathingIn.toggle()
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
        // Optional: tap to skip grounding
        .onTapGesture {
            currentScreen = .recording(mode)
        }
    }
}

#Preview {
    GroundingView(
        currentScreen: .constant(.grounding(.presentation)),
        mode: .presentation
    )
}
