//
//  Visit.swift
//  SalesMap
//
//  Created by Brandon Lackey on 9/11/25.
//

import Foundation
import CoreLocation

struct Visit: Codable, Identifiable {
    let id: String
    let customerId: String
    let userId: String
    let purpose: VisitPurpose
    let notes: String?
    let checkInTime: Date
    let checkOutTime: Date?
    let location: VisitLocation
    let photos: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, purpose, notes, location, photos
        case customerId = "customer_id"
        case userId = "user_id"
        case checkInTime = "check_in_time"
        case checkOutTime = "check_out_time"
    }
}

enum VisitPurpose: String, CaseIterable, Codable {
    case salesCall = "Sales call"
    case serviceVisit = "Service visit"
    case productDemo = "Product demonstration"
    case contractNegotiation = "Contract negotiation"
    case followUp = "Follow-up meeting"
    case other = "Other"
    
    var displayName: String {
        return self.rawValue
    }
}

struct VisitLocation: Codable {
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var clLocation: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Sample Data
extension Visit {
    static let sampleVisits: [Visit] = [
        Visit(
            id: "visit_001",
            customerId: "12345",
            userId: "rep_456",
            purpose: .salesCall,
            notes: "Discussed Q4 inventory needs. Customer interested in bulk pricing.",
            checkInTime: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
            checkOutTime: Calendar.current.date(byAdding: .hour, value: -1, to: Date()),
            location: VisitLocation(latitude: 37.3348, longitude: -122.0090),
            photos: nil
        ),
        Visit(
            id: "visit_002",
            customerId: "12346",
            userId: "rep_456",
            purpose: .productDemo,
            notes: "Demonstrated new software features. Very positive response.",
            checkInTime: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            checkOutTime: Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()),
            location: VisitLocation(latitude: 37.3230, longitude: -122.0322),
            photos: nil
        ),
        Visit(
            id: "visit_003",
            customerId: "12348",
            userId: "rep_456",
            purpose: .contractNegotiation,
            notes: "Finalized terms for annual contract. Signed deal worth $50k.",
            checkInTime: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            checkOutTime: Calendar.current.date(byAdding: .day, value: -2, to: Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()),
            location: VisitLocation(latitude: 37.3387, longitude: -122.0081),
            photos: nil
        ),
        Visit(
            id: "visit_004",
            customerId: "12349",
            userId: "rep_456",
            purpose: .followUp,
            notes: "Checked on implementation progress. Customer very satisfied.",
            checkInTime: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
            checkOutTime: Calendar.current.date(byAdding: .day, value: -3, to: Calendar.current.date(byAdding: .minute, value: 45, to: Date()) ?? Date()),
            location: VisitLocation(latitude: 37.3302, longitude: -122.0143),
            photos: nil
        )
    ]
}
