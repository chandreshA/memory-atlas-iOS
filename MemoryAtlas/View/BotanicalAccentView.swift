//
//  BotanicalAccentView.swift
//  MemoryAtlas
//
//  Created by Chandresh Ahir on 10/17/26.
//

import SwiftUI

struct BotanicalAccentView: View {
    var color: Color = AppTheme.sageGreen
    var length: CGFloat = 96

    var body: some View {
        Image("BindingMotif")
            .resizable()
            .renderingMode(.template)
            .scaledToFit()
            .foregroundStyle(color)
            // Frame the flower within the existing binding artwork.
            .frame(width: length * 1.6, height: length * 4.8)
            .offset(y: length * 0.3)
            .frame(width: length, height: length * 0.8)
            .clipped()
            .accessibilityHidden(true)
            .allowsHitTesting(false)
    }
}
