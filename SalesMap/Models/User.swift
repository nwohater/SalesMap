//
//  User.swift
//  SalesMap
//
//  Created by Brandon Lackey on 9/11/25.
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let territoryId: String
    let role: UserRole
    let isAuthenticated: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, role
        case territoryId = "territory_id"
        case isAuthenticated = "is_authenticated"
    }
}

enum UserRole: String, Codable, CaseIterable {
    case salesRep = "sales_rep"
    case salesManager = "sales_manager"
    case admin = "admin"
    
    var displayName: String {
        switch self {
        case .salesRep:
            return "Sales Representative"
        case .salesManager:
            return "Sales Manager"
        case .admin:
            return "Administrator"
        }
    }
}

// MARK: - Sample Data
extension User {
    static let mockUser = User(
        id: "rep_456",
        name: "Brandon Lackey",
        email: "brandon.lackey@company.com",
        territoryId: "CA-SOUTH",
        role: .salesRep,
        isAuthenticated: true
    )
}
