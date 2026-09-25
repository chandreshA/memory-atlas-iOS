//
//  TimelineView.swift
//  MemoryAtlas
//
//  Created by Chandresh Ahir on 9/22/26.
//

import Foundation
import SwiftUI

struct TimelineView: View {
    @ObservedObject var viewModel: TimelineViewModel

    init(viewModel: TimelineViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView("Loading Memories...")
                    .accessibilityIdentifier("timeline.loading")
            case .loaded(let memories):
                List {
                    ForEach(memories) { memory in
                        VStack(alignment: .leading) {
                            Text(memory.title)
                                .font(.headline)
                                .accessibilityLabel(memory.title)
                            Text(memory.memoryDate, format: .dateTime.month().day().year())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if let note = memory.note,
                               !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text(note)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
                .accessibilityIdentifier("timeline.list")
            case .idle:
                Text("No data")
                    .accessibilityIdentifier("timeline.idle")
            case .empty:
                Text("saved memories will appear here")
                    .accessibilityIdentifier("timeline.empty")
            case .failed(let error):
                VStack(spacing: 12) {
                    Text(error)
                        .accessibilityIdentifier("timeline.error")

                    Button("Try Again") {
                        Task {
                            await viewModel.load()
                        }
                    }
                    .accessibilityIdentifier("timeline.retryButton")
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

#if DEBUG

private struct PreviewMemoryRepository: MemoryRepository {
    let memories: [Memory]

    func fetchMemories() async throws -> [Memory] {
        memories
    }

    func save(_ memory: Memory) async throws {
        // Previews do not save anything.
    }
}

#Preview("Loaded Timeline") {
    let repository = PreviewMemoryRepository(
        memories: [
            Memory(
                id: UUID(),
                title: "Weekend in Montreal",
                note: "Found a tiny bookstore near the old port.",
                memoryDate: Date(timeIntervalSince1970: 1_750_000_000),
                creationDate: Date(timeIntervalSince1970: 1_750_000_100)
            ),
            Memory(
                id: UUID(),
                title: "Finished a Great Book",
                note: nil,
                memoryDate: Date(timeIntervalSince1970: 1_740_000_000),
                creationDate: Date(timeIntervalSince1970: 1_740_000_100)
            )
        ]
    )

    NavigationStack {
        TimelineView(
            viewModel: TimelineViewModel(memoryRepository: repository)
        )
        .navigationTitle("Timeline")
    }
}

#Preview("Empty Timeline") {
    let repository = PreviewMemoryRepository(memories: [])

    NavigationStack {
        TimelineView(
            viewModel: TimelineViewModel(memoryRepository: repository)
        )
        .navigationTitle("Timeline")
    }
}

#endif
