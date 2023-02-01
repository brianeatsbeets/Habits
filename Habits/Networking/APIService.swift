//
//  APIService.swift
//  Habits
//
//  Created by Aguirre, Brian P. on 1/25/23.
//

import UIKit

// This struct creates an API request for habits
struct HabitRequest: APIRequest {
    
    // The return type of the request
    typealias Response = [String: Habit]
    
    var habitName: String?
    
    // API endpoint
    var path: String { "/habits" }
}

// This struct creates an API request for users
struct UserRequest: APIRequest {
    
    // The return type of the request
    typealias Response = [String: User]
    
    // API endpoint
    var path: String { "/users" }
}

// This struct creates an API request for habit statistics
struct HabitStatisticsRequest: APIRequest {
    
    // The return type of the request
    typealias Response = [HabitStatistics]
    
    var habitNames: [String]?
    
    // API endpoint
    var path: String { "/habitStats" }
    
    // Parse multiple query items
    var queryItems: [URLQueryItem]? {
        if let habitNames = habitNames {
            return [URLQueryItem(name: "names", value: habitNames.joined(separator: ","))]
        } else {
            return nil
        }
    }
}

// This struct creates an API request for user statistics
struct UserStatisticsRequest: APIRequest {
    
    // The return type of the request
    typealias Response = [UserStatistics]
    
    var userIDs: [String]?
    
    // API endpoint
    var path: String { "/userStats" }
    
    // Parse multiple query items
    var queryItems: [URLQueryItem]? {
        if let userIDs = userIDs {
            return [URLQueryItem(name: "ids", value: userIDs.joined(separator: ","))]
        } else {
            return nil
        }
    }
}

// This struct creates an API request for user leading statistics
struct HabitLeadStatisticsRequest: APIRequest {
    
    // The return type of the request
    typealias Response = UserStatistics
    
    var userID: String
    
    // API endpoint
    var path: String { "/userLeadingStats/\(userID)" }
}

// This struct creates an API request for user images
struct ImageRequest: APIRequest {
    
    // The return type of the request
    typealias Response = UIImage
    
    var imageID: String
    
    // API endpoint
    var path: String { "/images/" + imageID }
}
