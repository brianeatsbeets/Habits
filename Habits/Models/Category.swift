//
//  Category.swift
//  Habits
//
//  Created by Aguirre, Brian P. on 1/25/23.
//

// This struct defines the Category model
struct Category {
    let name: String
    let color: Color
}

// This extension conforms to Codable
extension Category: Codable { }

// This extension conforms to Hashable
extension Category: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.name == rhs.name
    }
}
