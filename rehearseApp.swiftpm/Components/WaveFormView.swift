//
//  WaveFormView.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 2/6/26.
//

import SwiftUI

struct WaveformView: View {
    let audioLevel: Float
    let barCount: Int
    let isRecording: Bool
    
    @State private var levels: [CGFloat] = []
    
    init(audioLevel: Float, barCount: Int = 50, isRecording: Bool) {
        self.audioLevel = audioLevel
        self.barCount = barCount
        self.isRecording = isRecording
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(0..<levels.count, id: \.self) { index in
                WaveformBar(height: levels[index])
            }
        }
        .onAppear {
            levels = (0..<barCount).map { _ in CGFloat.random(in: 0.05...0.15) }
        }
        .onChange(of: audioLevel) { newLevel in
            updateLevels(with: CGFloat(newLevel))
        }
        .onChange(of: isRecording) { recording in
            if !recording {
                withAnimation(.easeOut(duration: 0.3)) {
                    levels = levels.map { _ in CGFloat.random(in: 0.05...0.15) }
                }
            }
        }
    }
    
    // Slides waveform forward by dropping oldest level
    private func updateLevels(with newLevel: CGFloat) {
        guard isRecording else { return }
        
        withAnimation(.easeOut(duration: 0.1)) {
            var newLevels = Array(levels.dropFirst())
            let variation = CGFloat.random(in: 0.8...1.2)
            let adjustedLevel = max(0.05, min(1.0, newLevel * variation))
            newLevels.append(adjustedLevel)
            levels = newLevels
        }
    }
}

// Bar representing one audio sample
struct WaveformBar: View {
    let height: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(AppTheme.primaryText.opacity(0.8))
            .frame(width: 3, height: max(4, height * 100))
    }
}

// Displays a mirrored waveform for a centered audio visual effect.
struct MirroredWaveformView: View {
    let audioLevel: Float
    let barCount: Int
    let isRecording: Bool
    
    @State private var levels: [CGFloat] = []
    
    init(audioLevel: Float, barCount: Int = 60, isRecording: Bool) {
        self.audioLevel = audioLevel
        self.barCount = barCount
        self.isRecording = isRecording
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(0..<levels.count, id: \.self) { index in
                MirroredBar(height: levels[index])
            }
        }
        .frame(height: 120)
        .onAppear {
            levels = (0..<barCount).map { _ in CGFloat.random(in: 0.05...0.2) }
        }
        .onChange(of: audioLevel) { newLevel in
            updateLevels(with: CGFloat(newLevel))
        }
        .onChange(of: isRecording) { recording in
            if !recording {
                withAnimation(.easeOut(duration: 0.5)) {
                    levels = levels.map { _ in CGFloat.random(in: 0.05...0.15) }
                }
            }
        }
    }
    // Updates mirrored waveform data using the latest audio level.
    private func updateLevels(with newLevel: CGFloat) {
        guard isRecording else { return }
        
        withAnimation(.linear(duration: 0.08)) {
            var newLevels = Array(levels.dropFirst())
            let variation = CGFloat.random(in: 0.7...1.3)
            let adjustedLevel = max(0.08, min(1.0, newLevel * variation))
            newLevels.append(adjustedLevel)
            levels = newLevels
        }
    }
}
// Renders a vertically mirrored pair of bars for symmetric visualization.
struct MirroredBar: View {
    let height: CGFloat
    
    var body: some View {
        VStack(spacing: 1) {
            RoundedRectangle(cornerRadius: 1.5)
                .fill(AppTheme.primaryText.opacity(0.85))
                .frame(width: 3, height: max(2, height * 50))
            
            RoundedRectangle(cornerRadius: 1.5)
                .fill(AppTheme.primaryText.opacity(0.85))
                .frame(width: 3, height: max(2, height * 50))
        }
    }
}

#Preview("Waveform") {
    ZStack {
        AppTheme.background
            .ignoresSafeArea()
        
        MirroredWaveformView(
            audioLevel: 0.5,
            isRecording: true
        )
        .padding()
    }
}
