//
//  CoreDataMemoryRepositoryTests.swift
//  MemoryAtlas
//
//  Created by Chandresh Ahir on 9/23/26.
//

import Foundation
import XCTest
@testable import MemoryAtlas
internal import CoreData

@MainActor
final class CoreDataMemoryRepositoryTests: XCTestCase {
    
    func testSaveAndFetchReturnsMemory() async throws {
        // Arrange
        let persistenceController = PersistenceController(inMemory: true)
        let repository = CoreDataMemoryRepository(context: persistenceController.container.viewContext)
        
        let expectedMemory = Memory(id: UUID(), title: "Trip to Tokyo", note: "Visited Shibuya", memoryDate: Date(timeIntervalSince1970: 1_000), creationDate: Date(timeIntervalSince1970: 2_000))
        
        // Act
        try await repository.save(expectedMemory)
        let memories = try await repository.fetchMemories()
        
        // Assert
        XCTAssertEqual(memories.count, 1)
        
        let savedMemory = try XCTUnwrap(memories.first)
        
        XCTAssertEqual(savedMemory.id, expectedMemory.id)
        XCTAssertEqual(savedMemory.title, expectedMemory.title)
        XCTAssertEqual(savedMemory.note, expectedMemory.note)
        XCTAssertEqual(savedMemory.memoryDate, expectedMemory.memoryDate)
        XCTAssertEqual(savedMemory.creationDate, expectedMemory.creationDate)
    }
    
    func testFetchMemoriesReturnsNewestFirst() async throws {
        let persistenceController = PersistenceController(inMemory: true)
        let repository = CoreDataMemoryRepository(context: persistenceController.container.viewContext)
        
        let memory1 = Memory(id: UUID(), title: "Trip to Tokyo", note: "Visited Shibuya", memoryDate: Date(timeIntervalSince1970: 1_000), creationDate: Date(timeIntervalSince1970: 3_000))
        let memory2 = Memory(id: UUID(), title: "Trip to London", note: "Visited Big Ben", memoryDate: Date(timeIntervalSince1970: 2_000), creationDate: Date(timeIntervalSince1970: 1_000))
        
        try await repository.save(memory1)
        try await repository.save(memory2)
        
        let memories = try await repository.fetchMemories()
        
        XCTAssertEqual(memories.map(\.id), [memory2.id, memory1.id])
    }
    
    func testSaveAndFetchPreservesNilNote() async throws {
        let persistenceController = PersistenceController(inMemory: true)
        let repository = CoreDataMemoryRepository(context: persistenceController.container.viewContext)
        
        let memory = Memory(id: UUID(), title: "Trip to London", memoryDate: Date(timeIntervalSince1970: 2_000), creationDate: Date(timeIntervalSince1970: 3_000))
        
        try await repository.save(memory)
        let memories = try await repository.fetchMemories()
        let fetchedMemory = try XCTUnwrap(memories.first)

        XCTAssertNil(fetchedMemory.note)
    }
}
