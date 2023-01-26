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
