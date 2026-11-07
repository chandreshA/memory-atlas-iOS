//
//  MemoryDetailView.swift
//  MemoryAtlas
//
//  Created by Chandresh Ahir on 10/18/26.
//

import SwiftUI

struct MemoryDetailView: View {
    @State private var memory: Memory
    @State private var isPresentingEditSheet: Bool = false
    @State private var isPresentingDeleteAlert: Bool = false
    @StateObject private var deleteViewModel: DeleteMemoryViewModel
    private let makeEditMemoryViewModel: (Memory) -> EditMemoryViewModel
    private let onUpdated: (Memory) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var deletedMemoryID: UUID?
    private let onDeleted: (UUID) -> Void

    init(
        memory: Memory,
        makeEditMemoryViewModel: @escaping (Memory) -> EditMemoryViewModel,
        makeDeleteMemoryViewModel: @escaping (Memory) -> DeleteMemoryViewModel,
        onUpdated: @escaping (Memory) -> Void,
        onDeleted: @escaping (UUID) -> Void
    ) {
        _memory = State(initialValue: memory)
        _deleteViewModel = StateObject(
            wrappedValue: makeDeleteMemoryViewModel(memory)
        )
        self.makeEditMemoryViewModel = makeEditMemoryViewModel
        self.onUpdated = onUpdated
        self.onDeleted = onDeleted
    }

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
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 12) {
                Rectangle()
                    .fill(AppTheme.forestGreen.opacity(0.25))
                    .frame(height: 1)
                    .accessibilityHidden(true)

                if deleteViewModel.isDeleting {
                    ProgressView("Deleting…")
                        .tint(AppTheme.forestGreen)
                        .foregroundStyle(AppTheme.inkGreen)
                        .accessibilityIdentifier("memoryDetail.deleting")
                }

                if case .failed(let message) = deleteViewModel.state {
                    Text(message)
                        .font(AppTheme.memoryBody)
                        .foregroundStyle(AppTheme.inkGreen)
                        .accessibilityIdentifier("memoryDetail.deleteError")
                }

                let layout = dynamicTypeSize.isAccessibilitySize
                    ? AnyLayout(VStackLayout(spacing: 12))
                    : AnyLayout(HStackLayout(spacing: 12))

                layout {
                    editButton
                    deleteButton
                }
                .disabled(deleteViewModel.isDeleting)
                .opacity(deleteViewModel.isDeleting ? 0.5 : 1)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
        }
        .safeAreaInset(edge: .leading, spacing: 0) {
            BindingStripView()
                .ignoresSafeArea(.container, edges: [.top, .bottom])
        }
        .background {
            ArchivePaperSurface()
                .ignoresSafeArea()
        }
        .navigationTitle("Memory")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbarBackground(AppTheme.parchment, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .tint(AppTheme.forestGreen)
        .sheet(isPresented: $isPresentingEditSheet) {
            EditMemoryView(
                viewModel: makeEditMemoryViewModel(memory)
            ) { updatedMemory in
                memory = updatedMemory
                onUpdated(updatedMemory)
            }
        }
        .confirmationDialog(
            "Delete this memory?",
            isPresented: $isPresentingDeleteAlert,
            titleVisibility: .visible
        ) {
            Button("Delete Memory", role: .destructive) {
                deleteConfirmedMemory()
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete this memory. This action cannot be undone.")
        }
        .onDisappear {
            guard let deletedID = deletedMemoryID else {
                return
            }

            deletedMemoryID = nil
            onDeleted(deletedID)
        }
        .navigationBarBackButtonHidden(deleteViewModel.isDeleting)
    }

    private var editButton: some View {
        Button {
            edit()
        } label: {
            Label("Edit", systemImage: "pencil")
                .font(AppTheme.memoryTitle)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity, minHeight: 48)
                .foregroundStyle(AppTheme.parchment)
                .background(AppTheme.forestGreen, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Edit memory")
    }

    private func edit() {
        isPresentingEditSheet = true
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            delete()
        } label: {
            Label("Delete", systemImage: "trash")
                .font(AppTheme.memoryTitle)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity, minHeight: 48)
                .foregroundStyle(AppTheme.stampRed)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(AppTheme.stampRed.opacity(0.7), lineWidth: 1)
                }
                .contentShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Delete memory")
    }

    private func delete() {
        isPresentingDeleteAlert = true
    }

    private func deleteConfirmedMemory() {
        Task {
            await deleteViewModel.delete()

            if case .deleted(let deletedMemory) = deleteViewModel.state {
                deletedMemoryID = deletedMemory.id
                dismiss()
            }
        }
    }
}

#if DEBUG
private struct DetailPreviewRepository: MemoryRepository {
    func fetchMemories() async throws -> [Memory] {
        []
    }

    func save(_ memory: Memory) async throws {}

    func update(_ memory: Memory) async throws {}

    func delete(_ memory: Memory) async throws {}
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
        MemoryDetailView(
            memory: sampleMemory,
            makeEditMemoryViewModel: { memory in
                EditMemoryViewModel(
                    memory: memory,
                    memoryRepository: DetailPreviewRepository()
                )
            },
            makeDeleteMemoryViewModel: { memory in
                DeleteMemoryViewModel(
                    memoryRepository: DetailPreviewRepository(),
                    memory: memory
                )
            },
            onUpdated: { _ in },
            onDeleted: { _ in }
        )
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
        MemoryDetailView(
            memory: sampleMemory,
            makeEditMemoryViewModel: { memory in
                EditMemoryViewModel(
                    memory: memory,
                    memoryRepository: DetailPreviewRepository()
                )
            },
            makeDeleteMemoryViewModel: { memory in
                DeleteMemoryViewModel(
                    memoryRepository: DetailPreviewRepository(),
                    memory: memory
                )
            },
            onUpdated: { _ in },
            onDeleted: { _ in }
        )
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
        MemoryDetailView(
            memory: sampleMemory,
            makeEditMemoryViewModel: { memory in
                EditMemoryViewModel(
                    memory: memory,
                    memoryRepository: DetailPreviewRepository()
                )
            },
            makeDeleteMemoryViewModel: { memory in
                DeleteMemoryViewModel(
                    memoryRepository: DetailPreviewRepository(),
                    memory: memory
                )
            },
            onUpdated: { _ in },
            onDeleted: { _ in }
        )
    }
    .environment(\.dynamicTypeSize, .accessibility3)
}
#endif
