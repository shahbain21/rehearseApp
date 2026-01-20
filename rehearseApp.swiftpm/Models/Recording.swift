//
//  Recording.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/5/26.
//
import SwiftUI

struct Recording: Identifiable, Codable {
    let id: UUID
    let url: URL
    let date: Date
    let duration: TimeInterval
    let speakingTime: TimeInterval
    let pauses: [TimeInterval]
    let notes: String? 
}

extension Recording {

    var speakingRatio: Double {
        guard duration > 0 else { return 0 }
        return speakingTime / duration
    }

    var averagePauseDuration: TimeInterval {
        guard !pauses.isEmpty else { return 0 }
        return pauses.reduce(0, +) / Double(pauses.count)
    }

    var longPauseCount: Int {
        pauses.filter { $0 > 2.0 }.count
    }

    var speakingSegmentCount: Int {
        max(pauses.count - 1, 1)
    }

    var averageSpeakingSegmentLength: TimeInterval {
        speakingTime / Double(speakingSegmentCount)
    }
}
