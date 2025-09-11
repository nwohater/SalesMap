//
//  Customer.swift
//  SalesMap
//
//  Created by Brandon Lackey on 9/11/25.
//

import Foundation
import CoreLocation

struct Customer: Codable, Identifiable {
    let id: String
    let name: String
    let company: String
    let address: String
    let phone: String
    let email: String
    let tier: String
    let territoryId: String
    let lastContact: Date?
    let latitude: Double
    let longitude: Double
    let totalRevenue: Double
    let lastPurchase: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, name, company, address, phone, email, tier, latitude, longitude
        case territoryId = "territory_id"
        case lastContact = "last_contact"
        case totalRevenue = "total_revenue"
        case lastPurchase = "last_purchase"
    }
    
    // Computed property for CLLocationCoordinate2D
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // Computed property for CLLocation
    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Sample Data
extension Customer {
    static let sampleCustomers: [Customer] = [
        Customer(
            id: "12345",
            name: "John Smith",
            company: "ABC Manufacturing",
            address: "1 Apple Park Way, Cupertino, CA 95014",
            phone: "+1-408-555-0123",
            email: "john.smith@abcmfg.com",
            tier: "Gold",
            territoryId: "CA-SOUTH",
            lastContact: Calendar.current.date(byAdding: .day, value: -5, to: Date()),
            latitude: 37.3348,
            longitude: -122.0090,
            totalRevenue: 125000,
            lastPurchase: Calendar.current.date(byAdding: .day, value: -20, to: Date())
        ),
        Customer(
            id: "12346",
            name: "Sarah Johnson",
            company: "Tech Solutions Inc",
            address: "10600 N De Anza Blvd, Cupertino, CA 95014",
            phone: "+1-408-555-0124",
            email: "sarah.johnson@techsolutions.com",
            tier: "Silver",
            territoryId: "CA-SOUTH",
            lastContact: Calendar.current.date(byAdding: .day, value: -10, to: Date()),
            latitude: 37.3230,
            longitude: -122.0322,
            totalRevenue: 85000,
            lastPurchase: Calendar.current.date(byAdding: .day, value: -35, to: Date())
        ),
        Customer(
            id: "12347",
            name: "Mike Davis",
            company: "Davis Enterprises",
            address: "19501 Stevens Creek Blvd, Cupertino, CA 95014",
            phone: "+1-408-555-0125",
            email: "mike.davis@davisenterprise.com",
            tier: "Bronze",
            territoryId: "CA-SOUTH",
            lastContact: Calendar.current.date(byAdding: .day, value: -15, to: Date()),
            latitude: 37.3161,
            longitude: -122.0194,
            totalRevenue: 45000,
            lastPurchase: Calendar.current.date(byAdding: .day, value: -60, to: Date())
        ),
        Customer(
            id: "12348",
            name: "Lisa Chen",
            company: "Innovation Labs",
            address: "20525 Mariani Ave, Cupertino, CA 95014",
            phone: "+1-408-555-0126",
            email: "lisa.chen@innovationlabs.com",
            tier: "Gold",
            territoryId: "CA-SOUTH",
            lastContact: Calendar.current.date(byAdding: .day, value: -3, to: Date()),
            latitude: 37.3387,
            longitude: -122.0081,
            totalRevenue: 180000,
            lastPurchase: Calendar.current.date(byAdding: .day, value: -10, to: Date())
        ),
        Customer(
            id: "12349",
            name: "Robert Wilson",
            company: "Silicon Valley Dynamics",
            address: "10123 N Wolfe Rd, Cupertino, CA 95014",
            phone: "+1-408-555-0127",
            email: "robert.wilson@svdynamics.com",
            tier: "Silver",
            territoryId: "CA-SOUTH",
            lastContact: Calendar.current.date(byAdding: .day, value: -7, to: Date()),
            latitude: 37.3302,
            longitude: -122.0143,
            totalRevenue: 95000,
            lastPurchase: Calendar.current.date(byAdding: .day, value: -25, to: Date())
        ),
        Customer(
            id: "12350",
            name: "Amanda Rodriguez",
            company: "Future Tech Corp",
            address: "21275 Stevens Creek Blvd, Cupertino, CA 95014",
            phone: "+1-408-555-0128",
            email: "amanda.rodriguez@futuretech.com",
            tier: "Bronze",
            territoryId: "CA-SOUTH",
            lastContact: Calendar.current.date(byAdding: .day, value: -12, to: Date()),
            latitude: 37.3234,
            longitude: -122.0278,
            totalRevenue: 62000,
            lastPurchase: Calendar.current.date(byAdding: .day, value: -45, to: Date())
        )
    ]
}
