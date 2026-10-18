//
//  MemoryDetailView.swift
//  MemoryAtlas
//
//  Created by Chandresh Ahir on 10/18/26.
//

import SwiftUI

struct MemoryDetailView: View {
    let memory: Memory

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(memory.memoryDate, format: .dateTime.month(.wide).day().year())
                    .font(AppTheme.memoryDate)

                Text(memory.title)
                    .font(AppTheme.screenTitle)
                    .accessibilityAddTraits(.isHeader)

                if let note = memory.note,
                   !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(note)
                        .font(AppTheme.memoryBody)
                        .lineSpacing(5)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(AppTheme.inkGreen)
            .padding(24)
        }
        .background {
            ArchivePaperSurface()
                .ignoresSafeArea()
        }
        .safeAreaInset(edge: .leading, spacing: 0) {
            BindingStripView()
                .ignoresSafeArea(.container, edges: [.top, .bottom])
        }
        .navigationTitle("Memory")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(AppTheme.parchment, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .tint(AppTheme.forestGreen)
    }
}

#Preview("Memory Detail") {
    let sampleMemory = Memory(
        id: UUID(),
        title: "A Special Day at the Beach",
        note: "We collected seashells and watched the sunset.",
        memoryDate: Date(),
        creationDate: Date()
    )

    return NavigationStack {
        MemoryDetailView(memory: sampleMemory)
    }
}

#Preview("Title Only") {
    let sampleMemory = Memory(
        id: UUID(),
        title: "A Special Day at the Beach",
        note: nil,
        memoryDate: Date(),
        creationDate: Date()
    )

    return NavigationStack {
        MemoryDetailView(memory: sampleMemory)
    }
}

#Preview("Long Content · Large Text") {
    let sampleMemory = Memory(
        id: UUID(),
        title: "A Special Day at the Beach — Seashells, Sunset, and an Evening to Remember",
        note: """
        We collected seashells along the shore and stopped to examine every little pattern. \
        There was nowhere we needed to be, so we took the long way around the bay.

        By late afternoon, the beach had grown quiet. We sat near the water, sharing stories \
        and watching the light change over the waves. I wanted to remember how peaceful it felt.

        We stayed until the sunset faded, then found a little shop still serving ice cream. \
        Dinner could wait. We talked about coming back next summer and taking the same walk.

        We left with sandy shoes, a handful of shells, and a memory worth keeping.
        """,
        memoryDate: Date(),
        creationDate: Date()
    )

    return NavigationStack {
        MemoryDetailView(memory: sampleMemory)
    }
    .environment(\.dynamicTypeSize, .accessibility3)
}
