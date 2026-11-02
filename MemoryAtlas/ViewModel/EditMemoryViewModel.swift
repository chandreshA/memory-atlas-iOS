//
//  EditMemoryViewModel.swift
//  MemoryAtlas
//
//  Created by Chandresh Ahir on 10/21/26.
//

import Foundation
import Combine

@MainActor
final class EditMemoryViewModel: ObservableObject {
    enum State {
        case idle
        case saving
        case saved(Memory)
        case failed(String)
    }

    @Published private(set) var state: State = .idle
    @Published var title: String = ""
    @Published var note: String = ""
    @Published var memoryDate: Date = Date()
    private let memoryRepository: MemoryRepository
    private let originalMemory: Memory

    init(memory: Memory, memoryRepository: MemoryRepository) {
        self.originalMemory = memory
        self.memoryRepository = memoryRepository
        self.title = memory.title
        self.note = memory.note ?? ""
        self.memoryDate = memory.memoryDate
    }

    var isSaving: Bool {
        if case .saving = state {
            return true
        }

        return false
    }

    var canSave: Bool {
        !isSaving &&
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func save() async {
        guard !isSaving else {
            return
        }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty else {
            state = .failed("Please enter a title.")
            return
        }

        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)

        let updatedMemory = Memory(
            id: originalMemory.id,
            title: trimmedTitle,
            note: trimmedNote.isEmpty ? nil : trimmedNote,
            memoryDate: memoryDate,
            creationDate: originalMemory.creationDate
        )

        state = .saving

        do {
            try await memoryRepository.update(updatedMemory)
            state = .saved(updatedMemory)
        } catch {
            state = .failed("Couldn’t save your changes. Please try again.")
        }
    }
}
