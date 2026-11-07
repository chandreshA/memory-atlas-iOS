//
//  DeleteMemoryViewModel.swift
//  MemoryAtlas
//
//  Created by Chandresh Ahir on 11/6/26.
//

import Foundation
import Combine

@MainActor
final class DeleteMemoryViewModel: ObservableObject {
    enum State {
        case idle
        case deleting
        case deleted(Memory)
        case failed(String)
    }

    @Published private(set) var state: State = .idle

    private let memoryRepository: MemoryRepository
    private let memory: Memory

    init(memoryRepository: MemoryRepository, memory: Memory) {
        self.memoryRepository = memoryRepository
        self.memory = memory
    }

    var isDeleting: Bool {
        if case .deleting = state {
            return true
        }

        return false
    }

    func delete() async {
        guard !isDeleting else { return }

        state = .deleting

        do {
            try await memoryRepository.delete(memory)
            state = .deleted(memory)
        } catch {
            state = .failed("Couldn’t delete this memory. Please try again.")
        }
    }
}
