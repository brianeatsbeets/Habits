//
//  HabitStatistics.swift
//  Habits
//
//  Created by Aguirre, Brian P. on 1/30/23.
//

// This struct provides a container for statistics data for a given habit
struct HabitStatistics {
    let habit: Habit
    let userCounts: [UserCount]
}

// This extension conforms to Codable
extension HabitStatistics: Codable { }

// This extension conforms to Comparable
extension HabitCount: Comparable {
    static func < (lhs: HabitCount, rhs: HabitCount) -> Bool {
        return lhs.habit < rhs.habit
    }
}

// This struct provides a container for user count data
struct UserCount {
    let user: User
    let count: Int
}

// This extension conforms to Codable
extension UserCount: Codable { }

// This extension conforms to Hashable
extension UserCount: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(user)
    }
    
    static func ==(_ lhs: UserCount, _ rhs: UserCount) -> Bool {
        return lhs.user == rhs.user
    }
}
