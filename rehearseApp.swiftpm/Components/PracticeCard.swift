//
//  PracticeCard.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/1/26.
//

import SwiftUI

struct PracticeCard: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // ✅ Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 20))
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                isSelected
                ? Color.accentColor.opacity(0.1)
                : Color(.systemBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color.accentColor : Color.clear,
                        lineWidth: 2
                    )
            )
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8)
        }
        .buttonStyle(.plain)
    }
}
