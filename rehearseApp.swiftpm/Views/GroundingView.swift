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

            Circle()
                .fill(Color.blue.opacity(0.15))
                .frame(width: 200, height: 200)
                .scaleEffect(isBreathingIn ? 1.1 : 0.9)
                .animation(
                    .easeInOut(duration: 3),
                    value: isBreathingIn
                )

            Text(isBreathingIn ? "Inhale" : "Exhale")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)

            Text("Starting in \(secondsRemaining)…")
                .font(.system(size: 14))
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
        .onAppear {
            breathingTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                Task { @MainActor in
                    isBreathingIn.toggle()
                }
            }
        }        .onDisappear {
            breathingTimer?.invalidate()
        }
        .onReceive(countdownTimer) { _ in
            if secondsRemaining > 1 {
                secondsRemaining -= 1
            } else {
                currentScreen = .recording(mode)
            }
        }
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
