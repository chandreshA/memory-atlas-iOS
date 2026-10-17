//
//  AppTheme.swift
//  MemoryAtlas
//
//  Created by Chandresh Ahir on 9/30/26.
//

import SwiftUI

enum AppTheme {
    static let forestGreen = Color("ForestGreen")
    static let leafGreen = Color("LeafGreen")
    static let sageGreen = Color("SageGreen")
    static let parchment = Color("Parchment")
    static let memoryTitle = Font.system(.title3, design: .serif)
        .weight(.semibold)
    static let memoryBody = Font.body
    static let memoryDate = Font.caption
    static let screenTitle = Font.system(.largeTitle, design: .serif)
    // A darker forest ink for normal-size text on sage (at least 4.5:1 contrast).
    static let inkGreen = Color(red: 36.0 / 255, green: 73.0 / 255, blue: 40.0 / 255)
    static let stampRed = Color(
        red: 158.0 / 255,
        green: 63.0 / 255,
        blue: 44.0 / 255
    )
}
