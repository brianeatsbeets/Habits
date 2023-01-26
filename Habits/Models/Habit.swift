//
//  Habit.swift
//  Habits
//
//  Created by Aguirre, Brian P. on 1/25/23.
//

// This struct defines the Habit model
struct Habit {
    let name: String
    let category: Category
    let info: String
}

// This extension conforms to Codable
extension Habit: Codable { }

// This extension conforms to Hashable
extension Habit: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: Habit, rhs: Habit) -> Bool {
        return lhs.name == rhs.name
    }
}

// This extension conforms to Comparable
extension Habit: Comparable {
    static func < (lhs: Habit, rhs: Habit) -> Bool {
        return lhs.name < rhs.name
    }
}
