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
            }else{
                self.state = .loaded(memories)
            }
        }catch {
            self.state = .failed("Unable to load memories. Please try again.")
        }
        
        
    }
}
