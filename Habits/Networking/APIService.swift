//
//  APIService.swift
//  Habits
//
//  Created by Aguirre, Brian P. on 1/25/23.
//

import Foundation

// This struct creates an API request for habits
struct HabitRequest: APIRequest {
    
    // The return type of the request
    typealias Response = [String: Habit]
    
    var habitName: String?
    
    // API endpoint
    var path: String { "/habits" }
}
