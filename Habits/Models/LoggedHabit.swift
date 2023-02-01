//
//  LoggedHabit.swift
//  Habits
//
//  Created by Aguirre, Brian P. on 2/1/23.
//

import Foundation

// This struct provides a container for logged habit data
struct LoggedHabit {
    let userID: String
    let habitName: String
    let timestamp: Date
}

// This extension conforms to Codable
extension LoggedHabit: Codable { }
