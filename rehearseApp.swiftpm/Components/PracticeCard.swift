//
//  PracticeCard.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/1/26.
//

import SwiftUI

struct PracticeCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.blue.opacity(0.2) : Color.white.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isSelected ? .blue : .white.opacity(0.7))
                }

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))
                }

                Spacer()

                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected
                        ? Color.blue.opacity(0.15)
                        : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected
                                ? Color.blue.opacity(0.5)
                                : Color.white.opacity(0.1),
                            lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview("Practice Card") {
    ZStack {
        Color(red: 0.08, green: 0.08, blue: 0.14)
            .ignoresSafeArea()
        
        VStack(spacing: 12) {
            PracticeCard(
                icon: "person.fill.questionmark",
                title: "Interview",
                subtitle: "Answer clearly and confidently",
                isSelected: true
            ) {}
            
            PracticeCard(
                icon: "chart.bar.doc.horizontal",
                title: "Presentation",
                subtitle: "Practice pacing and emphasis",
                isSelected: false
            ) {}
        }
        .padding()
    }
}
