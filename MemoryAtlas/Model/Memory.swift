//
//  Memory.swift
//  MemoryAtlas
//
//  Created by Chandresh Ahir on 9/22/26.
//

import Foundation

struct Memory: Codable, Identifiable {
    let id: UUID
    var title: String
    var note: String?
    var memoryDate: Date
    let creationDate: Date
}
