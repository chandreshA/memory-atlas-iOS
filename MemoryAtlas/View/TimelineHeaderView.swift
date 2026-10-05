//
//  TimelineHeaderView.swift
//  MemoryAtlas
//
//  Created by Chandresh Ahir on 9/30/26.
//

import SwiftUI

struct TimelineHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Memory Atlas")
                .font(.system(.headline, design: .serif))

            Text("Timeline")
                .font(AppTheme.screenTitle)
                .accessibilityAddTraits(.isHeader)
        }
        .foregroundStyle(AppTheme.parchment)
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.forestGreen)
    }
}

#Preview {
    TimelineHeaderView()
}
