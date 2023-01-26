//
//  Settings.swift
//  Habits
//
//  Created by Aguirre, Brian P. on 1/26/23.
//

import Foundation

// This struct provides a shared instance of UserDefaults for storing favorite habits
// Normally this would be stored with other user-specific information, but we're only concerned about the active user account (other user data is simulated on the local server)
struct Settings {
    
    // This enum serves as a namespace to store key strings
    enum Setting {
        static let favoriteHabits = "favoriteHabits"
    }
    
    static var shared = Settings()
    private let defaults = UserDefaults.standard
    
    var favoriteHabits: [Habit] {
        get {
            return unarchiveJSON(key: Setting.favoriteHabits) ?? []
        }
        set {
            archiveJSON(value: newValue, key: Setting.favoriteHabits)
        }
    }
    
    // For this project, we're assuming JSON encoding and decoding will work, so we're using try! instead of a do/catch block
    private func archiveJSON<T: Encodable>(value: T, key: String) {
        let data = try! JSONEncoder().encode(value)
        let string = String(data: data, encoding: .utf8)
        defaults.set(string, forKey: key)
    }
    
    private func unarchiveJSON<T: Decodable>(key: String) -> T? {
        guard let string = defaults.string(forKey: key),
              let data = string.data(using: .utf8) else {
            return nil
        }
        
        return try! JSONDecoder().decode(T.self, from: data)
    }
}
