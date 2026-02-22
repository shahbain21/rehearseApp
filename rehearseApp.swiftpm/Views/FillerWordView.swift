//
//  FillerWordView.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 2/19/26.
//
import SwiftUI

struct FillerWordCard: View {
    let fillerWords: [String: Int]
    let perMinute: Double
    
    var sortedFillers: [(String, Int)] {
        fillerWords.sorted { $0.value > $1.value }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Filler Words")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
                
                Spacer()
                
                Text(String(format: "%.1f/min", perMinute))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(perMinute > 5 ? .orange : .green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        (perMinute > 5 ? Color.orange : Color.green)
                            .opacity(0.15)
                    )
                    .cornerRadius(6)
            }
            
            if sortedFillers.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("No filler words detected!")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
            } else {
                ForEach(sortedFillers, id: \.0) { word, count in
                    HStack {
                        Text("\"\(word)\"")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Mini bar
                        let maxCount = sortedFillers.first?.1 ?? 1
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.orange.opacity(0.6))
                            .frame(
                                width: CGFloat(count) / CGFloat(maxCount) * 80,
                                height: 8
                            )
                        
                        Text("\(count)×")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.orange)
                            .frame(width: 36, alignment: .trailing)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}
