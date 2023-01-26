//
//  Color.swift
//  Habits
//
//  Created by Aguirre, Brian P. on 1/25/23.
//

// This struct defines the Habit model
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
