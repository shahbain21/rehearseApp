//
//  VolumeFormView.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 2/20/26.
//

import SwiftUI

struct VolumeWaveform: View {
    let samples: [Float]
    
    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .center, spacing: 2) {
                ForEach(Array(samples.enumerated()), id: \.offset) { index, sample in
                    let normalized = normalizedHeight(sample)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(barColor(for: sample))
                        .frame(
                            width: max(2, (geo.size.width - CGFloat(samples.count) * 2) / CGFloat(samples.count)),
                            height: max(4, normalized * geo.size.height)
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
    
    private func normalizedHeight(_ sample: Float) -> CGFloat {
        // Map from dB range (-60...0) to 0...1
        let minDb: Float = -60.0
        let maxDb: Float = 0.0
        let clamped = max(minDb, min(sample, maxDb))
        return CGFloat((clamped - minDb) / (maxDb - minDb))
    }
    
    private func barColor(for sample: Float) -> Color {
        let normalized = normalizedHeight(sample)
        if normalized > 0.7 {
            return .green
        } else if normalized > 0.4 {
            return .cyan
        } else {
            return .white.opacity(0.3)
        }
    }
}
