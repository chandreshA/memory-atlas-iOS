//
//  TimelineViewModel.swift
//  MemoryAtlas
//
//  Created by Chandresh Ahir on 9/24/26.
//

import Foundation
import Combine

@MainActor
final class TimelineViewModel: ObservableObject {
    enum State {
        case idle
        case loading
        case loaded([Memory])
        case empty
        case failed(String)
    }
    
    @Published private(set) var state: State = .idle
    private let memoryRepository: MemoryRepository
    
    init(memoryRepository: MemoryRepository) {
        self.memoryRepository = memoryRepository
    }
    
    func load() async {
        state = .loading
        
        do {
            let memories = try await memoryRepository.fetchMemories()
            if memories.isEmpty {
                self.state = .empty
            } else {
                self.state = .loaded(memories)
            }
        } catch {
            self.state = .failed("Unable to load memories. Please try again.")
        }
        
        
    }

    func applyUpdate(_ updatedMemory: Memory) {
        guard case .loaded(var memories) = state,
              let index = memories.firstIndex(where: {
                  $0.id == updatedMemory.id
              }) else {
            return
        }

        memories[index] = updatedMemory
        memories.sort { $0.memoryDate > $1.memoryDate }

        state = .loaded(memories)
    }

    func applyDeletion(id: UUID) {
        guard case .loaded(var memories) = state else {
            return
        }

        memories.removeAll { $0.id == id }

        state = memories.isEmpty ? .empty : .loaded(memories)
    }
}
