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
    @Environment(\.calendar) private var calendar
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
                    .background {
                        ArchivePaperSurface()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 24)
                    .accessibilityIdentifier("timeline.loading")
            case .loaded(let memories):
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(memories.enumerated()), id: \.element.id) { index, memory in
                            VStack(alignment: .leading, spacing: 0) {
                                // Add chapter headings without changing repository ordering.
                                if index == 0 || !calendar.isDate(
                                    memories[index - 1].memoryDate,
                                    equalTo: memory.memoryDate,
                                    toGranularity: .month
                                ) {
                                    ArchiveMonthHeading(date: memory.memoryDate)
                                        .padding(.top, index == 0 ? 0 : 8)
                                }
                                MemoryTimelineRow(memory: memory)
                            }
                            .accessibilityElement(children: .contain)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                }
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
                .background {
                    ArchivePaperSurface()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
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
                .background {
                    ArchivePaperSurface()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            ArchivePaperSurface(tint: AppTheme.sageGreen, textureOpacity: 0.3)
                .ignoresSafeArea()
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            TimelineHeaderView {
                isPresentingCreateMemory = true
            }
        }
        .safeAreaInset(edge: .leading, spacing: 0) {
            BindingStripView()
                .ignoresSafeArea(.container, edges: [.top, .bottom])
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.load()
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

#Preview("Timeline · Large Text") {
    let repository = PreviewMemoryRepository(
        memories: [
            Memory(
                id: UUID(),
                title: "An ordinary Sunday",
                note: "A quiet morning, a good book, and nowhere to rush.",
                memoryDate: Date(timeIntervalSince1970: 1_750_000_000),
                creationDate: Date(timeIntervalSince1970: 1_750_000_100)
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
    .environment(\.dynamicTypeSize, .accessibility3)
}

#endif
