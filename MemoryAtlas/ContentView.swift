//
//  ContentView.swift
//  MemoryAtlas
//
//  Created by Chandresh Ahir on 9/9/26.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: TimelineViewModel
    var body: some View {
        NavigationStack {
            TimelineView(viewModel: viewModel)
                .navigationTitle("Timeline")
        }
    }
}
