//
//  WPMCard.swift
//  rehearseApp
//

import SwiftUI

struct ExpandableWPMCard: View {
    let result: WPMResult
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {

            // Compact header
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: AppTheme.Spacing.md) {
                    Image(systemName: "speedometer")
                        .font(AppTheme.Fonts.iconFont)
                        .foregroundColor(result.rating.color)
                        .frame(width: 24)

                    Text("Speaking Pace")
                        .font(AppTheme.Fonts.cardTitle)
                        .foregroundColor(AppTheme.primaryText)
                    Spacer()
                    // Words per minute stat
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(Int(result.wpm))")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.primaryText)
                        Text("wpm")
                            .font(AppTheme.Fonts.smallLabel)
                            .foregroundColor(AppTheme.tertiaryText)
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.tertiaryText)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
            }
            .buttonStyle(.plain)

            // Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Divider()
                        .overlay(AppTheme.border)
                        .padding(.vertical, AppTheme.Spacing.sm)

                    // Rating + total word count
                    HStack {
                        Text(result.rating.label)
                            .font(AppTheme.Fonts.smallLabel)
                            .foregroundColor(result.rating.color)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(result.rating.color.opacity(0.15))
                            .cornerRadius(AppTheme.Spacing.sm)

                        Spacer()

                        Text("\(result.wordCount) words total")
                            .font(AppTheme.Fonts.cardSubtitle)
                            .foregroundColor(AppTheme.tertiaryText)
                    }
                    paceBar
                    // Short description of pace
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: result.rating.icon)
                            .font(.system(size: 14))
                            .foregroundColor(result.rating.color)
                            .frame(width: 20)
                        Text(result.rating.description)
                            .font(AppTheme.Fonts.cardSubtitle)
                            .foregroundColor(AppTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(AppTheme.Spacing.lg)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.Radius.card)
    }

    private var paceBar: some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppTheme.border)
                        .frame(height: 8)

                    let idealStart = (130.0 / 250.0) * geo.size.width
                    let idealEnd = min(1, (170.0 / 250.0)) * geo.size.width

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.green.opacity(0.3))
                        .frame(width: idealEnd - idealStart, height: 8)
                        .offset(x: idealStart)

                    let position = min(1, max(0, result.wpm / 250.0)) * geo.size.width

                    Circle()
                        .fill(result.rating.color)
                        .frame(width: 16, height: 16)
                        .offset(x: position - 8)
                }
            }
            .frame(height: 16)

            HStack {
                Text("Slow")
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.mutedText)
                Spacer()
                Text("Ideal")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.green)
                Spacer()
                Text("Fast")
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.mutedText)
            }
        }
    }
}

// Previews

#Preview("Ideal") {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        ExpandableWPMCard(result: WPMResult(wpm: 148, wordCount: 296, duration: 120))
            .padding()
    }
}

#Preview("Too Fast") {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        ExpandableWPMCard(result: WPMResult(wpm: 210, wordCount: 350, duration: 100))
            .padding()
    }
}
