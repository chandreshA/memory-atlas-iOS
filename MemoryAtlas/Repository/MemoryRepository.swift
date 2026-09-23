//
//  MemoryRepository.swift
//  MemoryAtlas
//
//  Created by Chandresh Ahir on 9/23/26.
//

protocol MemoryRepository {
    func fetchMemories() async throws -> [Memory]
    func save(_ memory: Memory) async throws
}
