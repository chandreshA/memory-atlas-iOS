//
//  BindingStripView.swift
//  MemoryAtlas
//
//  Created by Chandresh Ahir on 10/5/26.
//

import SwiftUI

struct BindingStripView: View {
    var body: some View {
        ArchiveFloralBorder()
        .background(AppTheme.forestGreen)
        .clipped()
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(AppTheme.parchment.opacity(0.25))
                .frame(width: 1)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

#Preview {
    BindingStripView()
        .frame(height: 600)
}
