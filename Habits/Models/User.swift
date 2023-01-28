//
//  User.swift
//  Habits
//
//  Created by Aguirre, Brian P. on 1/28/23.
//

// This struct represents the model for the User type
struct User {
    let id: String
    let name: String
    let color: Color?
    let bio: String?
}

// This extension conforms to Codable
extension User: Codable { }

// This extension conforms to Hashable
extension User: Hashable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// This extension conforms to Comparable
extension User: Comparable {
    static func < (lhs: User, rhs: User) -> Bool {
        return lhs.name < rhs.name
    }
}
