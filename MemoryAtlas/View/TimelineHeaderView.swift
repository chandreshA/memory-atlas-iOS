//
//  TimelineHeaderView.swift
//  MemoryAtlas
//
//  Created by Chandresh Ahir on 9/30/26.
//

import SwiftUI

struct TimelineHeaderView: View {
    var onAddMemory: () -> Void = {}

    @ScaledMetric(relativeTo: .largeTitle) private var titleSize: CGFloat = 42

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Memory Atlas")
                    .font(.system(.title3, design: .serif))

                Text("Timeline")
                    .font(.system(size: titleSize, design: .serif))
                    .accessibilityAddTraits(.isHeader)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onAddMemory) {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundStyle(AppTheme.forestGreen)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.sageGreen, in: Circle())
                    .overlay {
                        Circle().strokeBorder(AppTheme.parchment.opacity(0.5))
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add Memory")
            .accessibilityIdentifier("timeline.addButton")
        }
        .foregroundStyle(AppTheme.parchment)
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .background {
            GeometryReader { geometry in
                Image("InkLandscape")
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width * 0.85,
                        height: geometry.size.height,
                        alignment: .bottomTrailing
                    )
                    .clipped()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .opacity(0.8)
                    .mask {
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0.2),
                                .init(color: .black.opacity(0.2), location: 0.4),
                                .init(color: .black, location: 0.75)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
            }
            .accessibilityHidden(true)
            .allowsHitTesting(false)
        }
        .background(AppTheme.forestGreen)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(AppTheme.leafGreen.opacity(0.5))
                .frame(height: 1)
                .accessibilityHidden(true)
                .allowsHitTesting(false)
        }
    }
}

#Preview {
    TimelineHeaderView()
}
