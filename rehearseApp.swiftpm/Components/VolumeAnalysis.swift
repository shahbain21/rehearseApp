//
//  VolumeAnalysis.swift
//  rehearseApp
//

import Foundation

struct VolumeAnalysis {
    let averageVolume: Float
    let volumeRange: Float        // max - min
    let variationScore: Double    // 0-100, higher = more dynamic
    let isMonotone: Bool
    
    static func analyze(_ samples: [Float]) -> VolumeAnalysis {
        guard !samples.isEmpty else {
            return VolumeAnalysis(
                averageVolume: 0,
                volumeRange: 0,
                variationScore: 0,
                isMonotone: true
            )
        }
        
        let avg = samples.reduce(0, +) / Float(samples.count)
        let minV = samples.min() ?? 0
        let maxV = samples.max() ?? 0
        let range = maxV - minV
        
        // Standard deviation
        let variance = samples.reduce(0) { $0 + pow($1 - avg, 2) } / Float(samples.count)
        let stdDev = sqrt(variance)
        
        // Normalize to 0-100 score
        // Good speakers have stdDev around 8-15 dB
        let variationScore = min(100, Double(stdDev / 12.0) * 100)
        let isMonotone = stdDev < 4.0
        
        return VolumeAnalysis(
            averageVolume: avg,
            volumeRange: range,
            variationScore: variationScore,
            isMonotone: isMonotone
        )
    }
}
