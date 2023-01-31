//
//  UserStatistics.swift
//  Habits
//
//  Created by Aguirre, Brian P. on 1/30/23.
//

// This struct provides a container for statistics data for a given user
struct UserStatistics {
    let user: User
    let habitCounts: [HabitCount]
}

// This extension conforms to Codable
extension UserStatistics: Codable { }

// This struct provides a container for habit count data
struct HabitCount {
    let habit: Habit
    let count: Int
}

// This extension conforms to Codable
extension HabitCount: Codable { }

// This extension conforms to Hashable
extension HabitCount: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(habit)
    }
    
    static func ==(_ lhs: HabitCount, _ rhs: HabitCount) -> Bool {
        return lhs.habit == rhs.habit
    }
}
