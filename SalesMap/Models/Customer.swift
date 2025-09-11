//
//  Customer.swift
//  SalesMap
//
//  Created by Brandon Lackey on 9/11/25.
//

import Foundation
import CoreLocation

// MARK: - Delivery Model
struct Delivery: Codable, Identifiable {
    let id: String
    let customerId: String
    let date: Date
    let total: Double
    let orderNumber: String
    let status: DeliveryStatus

    enum CodingKeys: String, CodingKey {
        case id, date, total, status
        case customerId = "customer_id"
        case orderNumber = "order_number"
    }
}

enum DeliveryStatus: String, Codable, CaseIterable {
    case delivered = "delivered"
    case pending = "pending"
    case cancelled = "cancelled"

    var displayName: String {
        switch self {
        case .delivered:
            return "Delivered"
        case .pending:
            return "Pending"
        case .cancelled:
            return "Cancelled"
        }
    }

    var color: String {
        switch self {
        case .delivered:
            return "green"
        case .pending:
            return "orange"
        case .cancelled:
            return "red"
        }
    }
}

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

// MARK: - Sample Delivery Data
extension Delivery {
    static let sampleDeliveries: [Delivery] = [
        // Deliveries for John Smith (ABC Manufacturing) - Last 5
        Delivery(
            id: "del_001",
            customerId: "12345",
            date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            total: 15750.00,
            orderNumber: "ORD-2024-101",
            status: .delivered
        ),
        Delivery(
            id: "del_002",
            customerId: "12345",
            date: Calendar.current.date(byAdding: .day, value: -20, to: Date()) ?? Date(),
            total: 22300.00,
            orderNumber: "ORD-2024-102",
            status: .delivered
        ),
        Delivery(
            id: "del_003",
            customerId: "12345",
            date: Calendar.current.date(byAdding: .day, value: -35, to: Date()) ?? Date(),
            total: 18950.00,
            orderNumber: "ORD-2024-103",
            status: .delivered
        ),
        Delivery(
            id: "del_004",
            customerId: "12345",
            date: Calendar.current.date(byAdding: .day, value: -50, to: Date()) ?? Date(),
            total: 12400.00,
            orderNumber: "ORD-2024-104",
            status: .delivered
        ),
        Delivery(
            id: "del_005",
            customerId: "12345",
            date: Calendar.current.date(byAdding: .day, value: -65, to: Date()) ?? Date(),
            total: 19800.00,
            orderNumber: "ORD-2024-105",
            status: .delivered
        ),

        // Deliveries for Sarah Johnson (Tech Solutions Inc) - Last 3
        Delivery(
            id: "del_006",
            customerId: "12346",
            date: Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date(),
            total: 8750.00,
            orderNumber: "ORD-2024-201",
            status: .delivered
        ),
        Delivery(
            id: "del_007",
            customerId: "12346",
            date: Calendar.current.date(byAdding: .day, value: -40, to: Date()) ?? Date(),
            total: 11200.00,
            orderNumber: "ORD-2024-202",
            status: .delivered
        ),
        Delivery(
            id: "del_008",
            customerId: "12346",
            date: Calendar.current.date(byAdding: .day, value: -70, to: Date()) ?? Date(),
            total: 6500.00,
            orderNumber: "ORD-2024-203",
            status: .delivered
        ),

        // Deliveries for Lisa Chen (Innovation Labs) - Last 4
        Delivery(
            id: "del_009",
            customerId: "12348",
            date: Calendar.current.date(byAdding: .day, value: -8, to: Date()) ?? Date(),
            total: 28500.00,
            orderNumber: "ORD-2024-301",
            status: .delivered
        ),
        Delivery(
            id: "del_010",
            customerId: "12348",
            date: Calendar.current.date(byAdding: .day, value: -25, to: Date()) ?? Date(),
            total: 31200.00,
            orderNumber: "ORD-2024-302",
            status: .delivered
        ),
        Delivery(
            id: "del_011",
            customerId: "12348",
            date: Calendar.current.date(byAdding: .day, value: -45, to: Date()) ?? Date(),
            total: 24800.00,
            orderNumber: "ORD-2024-303",
            status: .delivered
        ),
        Delivery(
            id: "del_012",
            customerId: "12348",
            date: Calendar.current.date(byAdding: .day, value: -60, to: Date()) ?? Date(),
            total: 33750.00,
            orderNumber: "ORD-2024-304",
            status: .delivered
        ),

        // Deliveries for Robert Wilson (Silicon Valley Dynamics) - Last 2
        Delivery(
            id: "del_013",
            customerId: "12349",
            date: Calendar.current.date(byAdding: .day, value: -18, to: Date()) ?? Date(),
            total: 14300.00,
            orderNumber: "ORD-2024-401",
            status: .delivered
        ),
        Delivery(
            id: "del_014",
            customerId: "12349",
            date: Calendar.current.date(byAdding: .day, value: -55, to: Date()) ?? Date(),
            total: 16750.00,
            orderNumber: "ORD-2024-402",
            status: .delivered
        )
    ]
}


