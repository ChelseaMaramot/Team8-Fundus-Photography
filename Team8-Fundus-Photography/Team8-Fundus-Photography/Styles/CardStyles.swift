//
//  CardStyles.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-01-09.
//
import SwiftUI

extension Color {
    init(hex: Int) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0
        )
    }
}

struct cardColors: Hashable {
    var white = Color(hex: 0xffffff)
    var cardBackground = Color(hex: 0xCAD6FF)
    var cardSubText = Color.black
    var cardMainText = Color(hex: 0x2260FF)
  
    init(){}
}

struct cardSpacing: Hashable {
    var cardOuterCornerRadius = CGFloat(17)
    var cardInnerCornerRadius = CGFloat(13)
}
