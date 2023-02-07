//
//  Color.swift
//  Habits
//
//  Created by Aguirre, Brian P. on 1/25/23.
//

import UIKit

// This struct defines the Color model
struct Color {
    let hue: Double
    let saturation: Double
    let brightness: Double
}

// This extension conforms to Codable
extension Color: Codable {
    
    // Define custom coding keys
    enum CodingKeys: String, CodingKey {
        case hue = "h"
        case saturation = "s"
        case brightness = "b"
    }
}

// This extension provides a UIColor convenience property
extension Color {
    var uiColor: UIColor {
        return UIColor(hue: CGFloat(hue), saturation: CGFloat(saturation), brightness: CGFloat(brightness), alpha: 1)
    }
}

// This extension conforms to Hashable
extension Color: Hashable { }
