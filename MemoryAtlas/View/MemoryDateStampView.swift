//
//  MemoryDateStampView.swift
//  MemoryAtlas
//
//  Created by Chandresh Ahir on 9/30/26.
//

import SwiftUI

struct MemoryDateStampView: View {
    let date: Date

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .caption) private var diameter: CGFloat = 60

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                Text(date, format: .dateTime.month().day().year())
                    .font(AppTheme.memoryBody)
                    .padding(10)
                    .background(
                        AppTheme.parchment,
                        in: RoundedRectangle(cornerRadius: 4)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 4)
                            .strokeBorder(AppTheme.stampRed, lineWidth: 1)
                    }
            } else {
                VStack(spacing: 1) {
                    Text(date, format: .dateTime.day())
                        .font(.system(.headline, design: .serif))

                    Text(date, format: .dateTime.month(.abbreviated))
                        .textCase(.uppercase)

                    Text(date, format: .dateTime.year())
                }
                .font(.caption2)
                .monospacedDigit()
                .frame(width: diameter, height: diameter)
                .background {
                    ArchivePaperSurface(textureOpacity: 0.4)
                        .clipShape(Circle())
                }
                .overlay {
                    Circle()
                        .strokeBorder(AppTheme.stampRed.opacity(0.9), lineWidth: 1.1)

                    Circle()
                        .inset(by: 4)
                        .strokeBorder(AppTheme.stampRed, lineWidth: 0.6)
                }
                .rotationEffect(.degrees(-8))
            }
        }
        .foregroundStyle(AppTheme.stampRed)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            Text(date, format: .dateTime.month(.wide).day().year())
        )
    }
}

#Preview {
    MemoryDateStampView(date: Date())
        .padding()
        .background(AppTheme.parchment)
}
