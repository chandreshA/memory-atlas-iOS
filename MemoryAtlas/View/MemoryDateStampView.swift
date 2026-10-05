//
//  MemoryDateStampView.swift
//  MemoryAtlas
//
//  Created by Chandresh Ahir on 9/30/26.
//

import SwiftUI

struct MemoryDateStampView: View {
    let date: Date

    var body: some View {
        Text(date, format: .dateTime.month().day().year())
            .font(AppTheme.memoryDate)
            .monospacedDigit()
            .foregroundStyle(AppTheme.forestGreen)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .overlay {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(
                        AppTheme.forestGreen,
                        style: StrokeStyle(
                            lineWidth: 1,
                            dash: [3, 2]
                        )
                    )
            }
    }
}

#Preview {
    MemoryDateStampView(date: Date())
        .padding()
        .background(AppTheme.parchment)
}
