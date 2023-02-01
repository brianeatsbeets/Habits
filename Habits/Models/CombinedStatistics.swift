//
//  CombinedStatistics.swift
//  Habits
//
//  Created by Aguirre, Brian P. on 2/1/23.
//

import Foundation

// This struct provides a container for combined statistics data
struct CombinedStatistics {
    let userStatistics: [UserStatistics]
    let habitStatistics: [HabitStatistics]
}

// This extension conforms to Codable
extension CombinedStatistics: Codable { }
