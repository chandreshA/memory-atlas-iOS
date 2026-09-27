//
//  CreateMemoryViewModel.swift
//  MemoryAtlas
//
//  Created by Chandresh Ahir on 9/26/26.
//

import Foundation
import Combine

@MainActor
final class CreateMemoryViewModel: ObservableObject {
    enum State {
        case idle
        case saving
        case saved
        case failed(String)
    }
    @Published private(set) var state: State = .idle
    @Published var title: String = ""
    @Published var note: String = ""
    @Published var memoryDate: Date = Date()
    private let memoryRepository: MemoryRepository
    private let idGenerator: () -> UUID
    private let dateProvider: () -> Date

    init(memoryRepository: MemoryRepository, idGenerator: @escaping () -> UUID = UUID.init, dateProvider: @escaping () -> Date = Date.init){
        self.memoryRepository = memoryRepository
        self.idGenerator = idGenerator
        self.dateProvider = dateProvider
    }

    var canSave: Bool {
        if case .saving = state { return false }
        return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func save() async {
        guard canSave else { state = .failed("Please enter a title."); return}
        state = .saving

        do {
            let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
            let savedNote: String? = trimmedNote.isEmpty ? nil : trimmedNote
            try await memoryRepository.save(Memory(id: idGenerator(), title: trimmedTitle, note: savedNote, memoryDate: memoryDate, creationDate: dateProvider()))
            self.state = .saved
        } catch {
            state = .failed("Failed to save memory. Please try again")
        }
    }
}
