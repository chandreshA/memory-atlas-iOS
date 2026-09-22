//
//  TimelineView.swift
//  MemoryAtlas
//
//  Created by Chandresh Ahir on 9/22/26.
//

import SwiftUI

struct TimelineView: View {
    private var memory: [Memory]

    init(memory: [Memory]) {
        self.memory = memory
    }

    var body: some View {
        List {
            ForEach(memory) { memory in
                EmptyView()
            }
        }
    }
}

#Preview {
    TimelineView(memory: [])
}
