//
//  MemoryAtlasApp.swift
//  MemoryAtlas
//
//  Created by Chandresh Ahir on 9/9/26.
//

import CoreData
import SwiftUI

@main
struct MemoryAtlasApp: App {
    private let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(
                    \.managedObjectContext,
                    persistenceController.container.viewContext
                )
        }
    }
}
