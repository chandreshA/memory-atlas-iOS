//
//  MemoryAtlasApp.swift
//  MemoryAtlas
//
//  Created by Chandresh Ahir on 9/9/26.
//
import SwiftUI
import CoreData

@main
struct MemoryAtlasApp: App {
    private let memoryRepository: CoreDataMemoryRepository
    private let persistenceController: PersistenceController
    @StateObject private var viewModel: TimelineViewModel

    init() {
        let persistenceController = PersistenceController(inMemory: false)
        let repository = CoreDataMemoryRepository(
            context: persistenceController.container.viewContext
        )

        self.persistenceController = persistenceController
        _viewModel = StateObject(
            wrappedValue: TimelineViewModel(memoryRepository: repository)
        )
        self.memoryRepository = repository
    }

    var body: some Scene {
        WindowGroup {
            ContentView(
                viewModel: viewModel,
                makeCreateMemoryViewModel: {
                    CreateMemoryViewModel(
                        memoryRepository: self.memoryRepository
                    )
                }
            )
        }
    }
}
