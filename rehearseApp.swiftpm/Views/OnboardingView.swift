//
//  OnboardingView.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 2/25/26.
//


import SwiftUI
import AVFoundation

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct OnboardingView: View {
    @Binding var currentScreen: AppScreen
    // Only shows on first time
    @AppStorage("hasCompletedOnboarding") private var hasCompleted = false
    @State private var currentPage = 0
    @State private var appeared = false

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "mic.fill",
            title: "Practice Speaking",
            description: "Record yourself in different modes — presentations, interviews, storytelling, or free speech.",
            color: .blue
        ),
        OnboardingPage(
            icon: "waveform.path.ecg",
            title: "Get Real Feedback",
            description: "See your pace, filler words, vocal energy, and more. All analyzed locally on your device.",
            color: .cyan
        ),
        OnboardingPage(
            icon: "chart.line.uptrend.xyaxis",
            title: "Improve Over Time",
            description: "Track your progress, reflect on sessions, and build confidence with every rep.",
            color: .green
        )
    ]

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()
                // Swipable page content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        pageView(page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)
                Spacer()

                // Current page index
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage
                                  ? AppTheme.accent
                                  : AppTheme.border)
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentPage ? 1.2 : 1)
                            .animation(.easeInOut(duration: 0.2), value: currentPage)
                    }
                }
                .padding(.bottom, AppTheme.Spacing.xl)

                VStack(spacing: AppTheme.Spacing.md) {
                    // Show Next and Skip until last page
                    if currentPage < pages.count - 1 {
                        Button {
                            withAnimation {
                                currentPage += 1
                            }
                        } label: {
                            Text("Next")
                                .font(AppTheme.Fonts.buttonLabel)
                                .foregroundColor(AppTheme.primaryText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppTheme.Spacing.lg)
                                .background(
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.button)
                                        .fill(AppTheme.accent)
                                )
                        }

                        // Marks onboarding as complete and skips
                        Button {
                            completeOnboarding()
                        } label: {
                            Text("Skip")
                                .font(AppTheme.Fonts.secondaryButton)
                                .foregroundColor(AppTheme.tertiaryText)
                        }
                    } else {
                        // Get Started button on last page
                        Button {
                            completeOnboarding()
                        } label: {
                            Text("Get Started")
                                .font(AppTheme.Fonts.buttonLabel)
                                .foregroundColor(AppTheme.primaryText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppTheme.Spacing.lg)
                                .background(
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.button)
                                        .fill(AppTheme.accent)
                                )
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.bottom, AppTheme.Spacing.xxl)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }

    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: AppTheme.Spacing.xl) {
            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.15))
                    .frame(width: 100, height: 100)

                Image(systemName: page.icon)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(page.color)
            }
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.8)

            // Title
            Text(page.title)
                .font(AppTheme.Fonts.screenTitle)
                .foregroundColor(AppTheme.primaryText)
                .multilineTextAlignment(.center)

            // Description
            Text(page.description)
                .font(AppTheme.Fonts.screenSubtitle)
                .foregroundColor(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.xl)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }

    // Asks for mic permission and completes onboarding
    private func completeOnboarding() {
        AVAudioSession.sharedInstance().requestRecordPermission { _ in }
        hasCompleted = true
        currentScreen = .home
    }
}

#Preview("Page 1") {
    OnboardingView(currentScreen: .constant(.home))
}
