//
//  ScoreCardView.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 2/20/26.
//

import SwiftUI

struct ScoreCard: View {
    let score: Int
    let tone: FeedbackTone
    let duration: String
    
    var body: some View {
        VStack(spacing: 16) {
            // Score ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 12)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: CGFloat(score) / 100)
                    .stroke(
                        tone.color,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text("\(score)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("/ 100")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            // Tone badge
            HStack(spacing: 6) {
                Image(systemName: tone.icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(tone.label)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(tone.color)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(tone.color.opacity(0.15))
            .cornerRadius(20)
            
            // Duration
            Text(duration)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
    }
}
