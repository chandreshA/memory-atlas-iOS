//
//  TimelineView.swift
//  MemoryAtlas
//
//  Created by Chandresh Ahir on 9/22/26.
//

import SwiftUI

struct TimelineView: View {
    private var memory: [Memory]

    init(memory: [Memory] = [Memory(id: 1, title: "some title", note: "adding notes", memoryDate: Date(), creationDate: Date()), Memory(id: 2, title: "some title", note: "adding notes", memoryDate: Date(), creationDate: Date()), Memory(id: 3, title: "some title3", note: "adding notes", memoryDate: Date(), creationDate: Date())]) {
        self.memory = memory
    }

    var body: some View {
        List {
            ForEach(memory) { memory in
                VStack(alignment: .leading) {
                    Text(memory.title)
                        .font(.headline)
                    Text(memory.note)
                        .font(.subheadline)
                }
            }
        }
    }
}

#Preview {
    TimelineView()
}
