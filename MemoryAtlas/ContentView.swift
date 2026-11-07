//
//  ContentView.swift
//  MemoryAtlas
//
//  Created by Chandresh Ahir on 9/9/26.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: TimelineViewModel
    let makeCreateMemoryViewModel: () -> CreateMemoryViewModel
    let makeEditMemoryViewModel: (Memory) -> EditMemoryViewModel
    let makeDeleteMemoryViewModel: (Memory) -> DeleteMemoryViewModel
    var body: some View {
        NavigationStack {
            TimelineView(
                viewModel: viewModel,
                makeCreateMemoryViewModel: makeCreateMemoryViewModel,
                makeEditMemoryViewModel: makeEditMemoryViewModel,
                makeDeleteMemoryViewModel: makeDeleteMemoryViewModel
            )
        }
    }
}
