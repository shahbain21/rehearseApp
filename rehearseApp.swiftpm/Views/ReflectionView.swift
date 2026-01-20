//
//  ReflectionView.swift
//  rehearseApp
//
//  Created by Mohamed Shahbain on 1/1/26.
//

import SwiftUI

struct ReflectionView: View {
    @Binding var currentScreen: AppScreen
    @State private var hardPart = ""
    @State private var goodPart = ""

    var body: some View {
        VStack(spacing: 24) {
            Text("Reflection")
                .font(.system(size: 24, weight: .semibold))

            Text("You don’t need to write much.\nA few words is enough.")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading) {
                Text("What felt hardest?")
                TextEditor(text: $hardPart)
                    .frame(height: 80)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3)))
            }

            VStack(alignment: .leading) {
                Text("What went better than expected?")
                TextEditor(text: $goodPart)
                    .frame(height: 80)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3)))
            }

            Button("Finish Session") {
                currentScreen = .history
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview("Reflection View") {
    ReflectionView(
        currentScreen: .constant(.reflection)
    )
}
