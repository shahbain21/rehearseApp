//
//  FeedbackTabSelector.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 2/20/26.
//
import SwiftUI

enum FeedbackTab: String, CaseIterable {
    case overview = "Overview"
    case details = "Details"
    case improve = "Improve"
}

struct FeedbackTabSelector: View {
    @Binding var selectedTab: FeedbackTab
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(FeedbackTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.5))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(selectedTab == tab ? Color.blue : Color.white.opacity(0.08))
                        )
                }
            }
        }
    }
}
