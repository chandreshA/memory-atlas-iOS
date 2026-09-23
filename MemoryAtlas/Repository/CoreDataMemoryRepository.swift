//
//  CoreDataMemoryRepository.swift
//  MemoryAtlas
//
//  Created by Chandresh Ahir on 9/23/26.
//

import CoreData

enum PersistenceError: Error {
    case missingRequiredField(String)
}


class CoreDataMemoryRepository: MemoryRepository {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchMemories() async throws -> [Memory] {
        try await context.perform { [context] in
            let request = NSFetchRequest<MemoryEntity>(entityName: "MemoryEntity")
            
            request.sortDescriptors = [NSSortDescriptor(keyPath: \MemoryEntity.memoryDate, ascending: false)]
            
            let entities = try context.fetch(request)
            
            return try entities.map { entity in
                guard let id = entity.id else {
                    throw PersistenceError.missingRequiredField("id")
                }
                guard let title = entity.title else {
                    throw PersistenceError.missingRequiredField("title")
                }
                guard let creationDate = entity.creationDate else {
                    throw PersistenceError.missingRequiredField("creationDate")
                }
                guard let memoryDate = entity.memoryDate else {
                    throw PersistenceError.missingRequiredField("memoryDate")
                }
                return Memory(
                    id: id,
                    title: title,
                    note: entity.note,
                    memoryDate: memoryDate,
                    creationDate: creationDate
                )
            }
        }
    }
    
    func save(_ memory: Memory) async throws {
        try await context.perform { [context] in
            let entity = MemoryEntity(context: context)
            
            entity.id = memory.id
            entity.title = memory.title
            entity.note = memory.note
            entity.memoryDate = memory.memoryDate
            entity.creationDate = memory.creationDate
            
            if context.hasChanges {
                try context.save()
            }
        }
    }
    
    
}
