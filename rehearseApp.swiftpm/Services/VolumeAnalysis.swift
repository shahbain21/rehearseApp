//
//  VolumeAnalysis.swift
//  rehearseApp
//

import Foundation

struct VolumeAnalysis {
    let averageVolume: Float
    let volumeRange: Float
    let variationScore: Double
    let isMonotone: Bool
    
    // Analyzes audio levels and returns VolumeAnalysis object
    static func analyze(_ samples: [Float]) -> VolumeAnalysis {
        guard !samples.isEmpty else {
            return VolumeAnalysis(
                averageVolume: 0,
                volumeRange: 0,
                variationScore: 0,
                isMonotone: true
            )
        }
        
        // Finds average volumne
        let avg = samples.reduce(0, +) / Float(samples.count)
        
        // Finds range of volume
        let minV = samples.min() ?? 0
        let maxV = samples.max() ?? 0
        let range = maxV - minV
        
        // Uses standard dev to find variation score
        let variance = samples.reduce(0) { $0 + pow($1 - avg, 2) } / Float(samples.count)
        let stdDev = sqrt(variance) // Good speakers have stdDev around 8-15 dB
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
