////
////  PauseBarView.swift
////  rehearseApp
////
////  Created by Mohamed Shahbain on 2/20/26.
////
//
//import SwiftUI
//
//struct PauseDistributionCard: View {
//    let distribution: PauseDistribution
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            Text("Pause Distribution")
//                .font(.system(size: 14, weight: .semibold))
//                .foregroundColor(.white.opacity(0.5))
//            
//            // Bar chart
//            HStack(alignment: .bottom, spacing: 12) {
//                PauseBar(label: "<0.5s", count: distribution.shortPauses, total: distribution.total, color: .green)
//                PauseBar(label: "0.5-1.5s", count: distribution.mediumPauses, total: distribution.total, color: .cyan)
//                PauseBar(label: "1.5-3s", count: distribution.longPauses, total: distribution.total, color: .yellow)
//                PauseBar(label: ">3s", count: distribution.veryLongPauses, total: distribution.total, color: .orange)
//            }
//            .frame(height: 100)
//            
//            // Analysis
//            Text(distribution.analysis)
//                .font(.system(size: 13))
//                .foregroundColor(.white.opacity(0.6))
//        }
//        .padding(16)
//        .background(Color.white.opacity(0.05))
//        .cornerRadius(16)
//    }
//}
//
//struct PauseBar: View {
//    let label: String
//    let count: Int
//    let total: Int
//    let color: Color
//    
//    private var height: CGFloat {
//        guard total > 0 else { return 10 }
//        return max(10, CGFloat(count) / CGFloat(total) * 80)
//    }
//    
//    var body: some View {
//        VStack(spacing: 8) {
//            Text("\(count)")
//                .font(.system(size: 12, weight: .bold))
//                .foregroundColor(.white)
//            
//            RoundedRectangle(cornerRadius: 4)
//                .fill(color)
//                .frame(height: height)
//            
//            Text(label)
//                .font(.system(size: 10))
//                .foregroundColor(.white.opacity(0.5))
//        }
//        .frame(maxWidth: .infinity)
//    }
//}
