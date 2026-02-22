//
//  VocalEnergySummary.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 2/20/26.
//

import SwiftUI

struct VocalEnergySummary: View {
    let samples: [Float]
    
    private var analysis: VolumeAnalysis {
        VolumeAnalysis.analyze(samples)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "speaker.wave.3")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(analysis.isMonotone ? .orange : .green)
                
                Text("Vocal Energy")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(analysis.isMonotone ? "Monotone" :
                     analysis.variationScore > 70 ? "Dynamic" : "Moderate")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(analysis.isMonotone ? .orange :
                                    analysis.variationScore > 70 ? .green : .cyan)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        (analysis.isMonotone ? Color.orange :
                         analysis.variationScore > 70 ? Color.green : Color.cyan)
                            .opacity(0.15)
                    )
                    .cornerRadius(8)
            }
            
            // Mini waveform
            VolumeWaveform(samples: samples)
                .frame(height: 40)
            
            Text(analysis.isMonotone ?
                "Your delivery sounds flat — try varying your volume to emphasize key points." :
                analysis.variationScore > 70 ?
                "Great vocal variety! You're naturally emphasizing points with your voice." :
                "Decent variation. Try pushing your emphasis a bit more on key moments.")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}


struct VocalEnergyDetailCard: View {
    let samples: [Float]
    
    private var analysis: VolumeAnalysis {
        VolumeAnalysis.analyze(samples)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Vocal Energy")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
            
            // Waveform
            VolumeWaveform(samples: samples)
                .frame(height: 60)
            
            // Stats row
            HStack(spacing: 16) {
                VocalStatBadge(
                    label: "Variation",
                    value: analysis.isMonotone ? "Low" :
                           analysis.variationScore > 70 ? "High" : "Medium",
                    color: analysis.isMonotone ? .orange :
                           analysis.variationScore > 70 ? .green : .cyan
                )
                
                VocalStatBadge(
                    label: "Range",
                    value: String(format: "%.0f dB", analysis.volumeRange),
                    color: analysis.volumeRange > 15 ? .green : .yellow
                )
                
                VocalStatBadge(
                    label: "Style",
                    value: analysis.isMonotone ? "Flat" : "Dynamic",
                    color: analysis.isMonotone ? .orange : .green
                )
            }
            
            Text(analysis.isMonotone ?
                "Your volume stays very consistent throughout. Varying your loudness helps emphasize key points and keeps listeners engaged." :
                analysis.variationScore > 70 ?
                "Excellent vocal dynamics! You naturally vary your volume, which makes your delivery engaging and expressive." :
                "You have some vocal variation. Try pushing your emphasis a bit more — get louder for key points, softer for reflective moments.")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

struct VocalStatBadge: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}
