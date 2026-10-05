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
    @State private var isPresentingCreateMemory = false
    private let makeCreateMemoryViewModel: () -> CreateMemoryViewModel

    init(
        viewModel: TimelineViewModel,
        makeCreateMemoryViewModel: @escaping () -> CreateMemoryViewModel
    ) {
        self.viewModel = viewModel
        self.makeCreateMemoryViewModel = makeCreateMemoryViewModel
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView("Loading memories…")
                    .font(AppTheme.memoryBody)
                    .tint(AppTheme.forestGreen)
                    .foregroundStyle(AppTheme.forestGreen)
                    .padding(24)
                    .background(
                        AppTheme.parchment,
                        in: RoundedRectangle(cornerRadius: 12)
                    )
                    .padding(.horizontal, 24)
                    .accessibilityIdentifier("timeline.loading")
            case .loaded(let memories):
                List {
                    ForEach(memories) { memory in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(memory.title)
                                .font(AppTheme.memoryTitle)
                                .accessibilityLabel(memory.title)
                            MemoryDateStampView(date: memory.memoryDate)
                            if let note = memory.note,
                               !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text(note)
                                    .font(AppTheme.memoryBody)
                                    .foregroundStyle(AppTheme.forestGreen)
                            }
                        }
                        .accessibilityElement(children: .combine)
                        .foregroundStyle(AppTheme.forestGreen)
                        .listRowBackground(AppTheme.parchment)
                    }
                }
                .scrollContentBackground(.hidden)
                .accessibilityIdentifier("timeline.list")
            case .idle:
                Text("No data")
                    .accessibilityIdentifier("timeline.idle")
            case .empty:
                VStack(spacing: 12) {
                    Image(systemName: "book.closed")
                        .font(.largeTitle)
                        .accessibilityHidden(true)
                    Text("Your story starts here")
                        .font(AppTheme.memoryTitle)
                        .accessibilityAddTraits(.isHeader)
                    Text("Add a memory to begin your personal archive.")
                        .font(AppTheme.memoryBody)
                        .multilineTextAlignment(.center)
                }
                .foregroundStyle(AppTheme.forestGreen)
                .padding(24)
                .background(
                    AppTheme.parchment,
                    in: RoundedRectangle(cornerRadius: 12)
                )
                .padding(.horizontal, 24)
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("timeline.empty")
            case .failed(let error):
                VStack(spacing: 12) {
                    Text("Couldn’t load your memories")
                        .font(AppTheme.memoryTitle)
                        .accessibilityAddTraits(.isHeader)
                    
                    Text(error)
                        .font(AppTheme.memoryBody)
                        .multilineTextAlignment(.center)
                        .accessibilityIdentifier("timeline.error")

                    Button("Try Again") {
                        Task {
                            await viewModel.load()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(AppTheme.forestGreen)
                    .foregroundStyle(AppTheme.parchment)
                    .accessibilityIdentifier("timeline.retryButton")
                }
                .foregroundStyle(AppTheme.forestGreen)
                .padding(24)
                .background(
                    AppTheme.parchment,
                    in: RoundedRectangle(cornerRadius: 12)
                )
                .padding(.horizontal, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.sageGreen.ignoresSafeArea())
        .safeAreaInset(edge: .top, spacing: 0) {
            TimelineHeaderView()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.forestGreen, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await viewModel.load()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isPresentingCreateMemory = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(AppTheme.parchment)
                }
                .accessibilityLabel("Add Memory")
                .accessibilityIdentifier("timeline.addButton")
            }
        }
        .sheet(isPresented: $isPresentingCreateMemory) {
            CreateMemoryView(
                viewModel: makeCreateMemoryViewModel(),
                onSaved: {
                    await viewModel.load()
                }
            )
        }
    }
}

#if DEBUG

private struct PreviewMemoryRepository: MemoryRepository {
    let memories: [Memory]
    var delay: Duration = .zero
    var shouldFail = false
    
    private enum PreviewError: Error {
        case fetchFailed
    }
    
    func fetchMemories() async throws -> [Memory] {
        try await Task.sleep(for: delay)
        
        if shouldFail {
            throw PreviewError.fetchFailed
        }
        
        return memories
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
            viewModel: TimelineViewModel(memoryRepository: repository),
            makeCreateMemoryViewModel: {
                CreateMemoryViewModel(memoryRepository: repository)
            }
        )
    }
}

#Preview("Empty Timeline") {
    let repository = PreviewMemoryRepository(memories: [])
    
    NavigationStack {
        TimelineView(
            viewModel: TimelineViewModel(memoryRepository: repository),
            makeCreateMemoryViewModel: {
                CreateMemoryViewModel(memoryRepository: repository)
            }
        )
    }
}

#Preview("Loading Timeline") {
    let repository = PreviewMemoryRepository(
        memories: [],
        delay: .seconds(60)
    )
    
    NavigationStack {
        TimelineView(
            viewModel: TimelineViewModel(memoryRepository: repository),
            makeCreateMemoryViewModel: {
                CreateMemoryViewModel(memoryRepository: repository)
            }
        )
    }
}

#Preview("Error Timeline") {
    let repository = PreviewMemoryRepository(
        memories: [],
        shouldFail: true
    )
    
    NavigationStack {
        TimelineView(
            viewModel: TimelineViewModel(memoryRepository: repository),
            makeCreateMemoryViewModel: {
                CreateMemoryViewModel(memoryRepository: repository)
            }
        )
    }
}

#endif
