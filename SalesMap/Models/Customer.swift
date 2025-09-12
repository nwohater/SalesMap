//
//  Customer.swift
//  SalesMap
//
//  Created by Brandon Lackey on 9/11/25.
//

import Foundation
import CoreLocation

// MARK: - Order Item Model
struct OrderItem: Codable, Identifiable, Hashable {
    let id: String
    let productName: String
    let productCode: String
    let quantity: Int
    let unitPrice: Double
    let totalPrice: Double

    var formattedUnitPrice: String {
        "$\(String(format: "%.2f", unitPrice))"
    }

    var formattedTotalPrice: String {
        "$\(String(format: "%.2f", totalPrice))"
    }
}

// MARK: - Delivery Model
struct Delivery: Codable, Identifiable, Hashable {
    let id: String
    let customerId: String
    let date: Date
    let total: Double
    let orderNumber: String
    let status: DeliveryStatus
    let items: [OrderItem]
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case id, date, total, status, items, notes
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

// MARK: - Sample OrderItem Data
extension OrderItem {
    static let sampleOrderItems: [OrderItem] = [
        // Items for del_001 (ORD-2024-101) - Total: $15,750
        OrderItem(id: "item_001", productName: "Industrial Pump Model X200", productCode: "IPX200", quantity: 5, unitPrice: 2500.00, totalPrice: 12500.00),
        OrderItem(id: "item_002", productName: "Pressure Valve Set", productCode: "PVS-100", quantity: 10, unitPrice: 125.00, totalPrice: 1250.00),
        OrderItem(id: "item_003", productName: "Installation Kit", productCode: "IK-STD", quantity: 2, unitPrice: 1000.00, totalPrice: 2000.00),

        // Items for del_002 (ORD-2024-102) - Total: $22,300
        OrderItem(id: "item_004", productName: "Heavy Duty Motor 50HP", productCode: "HDM50", quantity: 2, unitPrice: 8500.00, totalPrice: 17000.00),
        OrderItem(id: "item_005", productName: "Control Panel Assembly", productCode: "CPA-200", quantity: 1, unitPrice: 3500.00, totalPrice: 3500.00),
        OrderItem(id: "item_006", productName: "Safety Switch Kit", productCode: "SSK-PRO", quantity: 4, unitPrice: 450.00, totalPrice: 1800.00),

        // Items for del_003 (ORD-2024-103) - Total: $18,950
        OrderItem(id: "item_007", productName: "Hydraulic Cylinder 12\"", productCode: "HC12", quantity: 3, unitPrice: 4500.00, totalPrice: 13500.00),
        OrderItem(id: "item_008", productName: "Hydraulic Fluid 55gal", productCode: "HF55", quantity: 8, unitPrice: 275.00, totalPrice: 2200.00),
        OrderItem(id: "item_009", productName: "Maintenance Tools Set", productCode: "MTS-PRO", quantity: 1, unitPrice: 3250.00, totalPrice: 3250.00),

        // Items for del_006 (ORD-2024-201) - Total: $8,750
        OrderItem(id: "item_010", productName: "Server Rack 42U", productCode: "SR42U", quantity: 2, unitPrice: 1200.00, totalPrice: 2400.00),
        OrderItem(id: "item_011", productName: "Network Switch 48-Port", productCode: "NS48P", quantity: 3, unitPrice: 850.00, totalPrice: 2550.00),
        OrderItem(id: "item_012", productName: "Cable Management Kit", productCode: "CMK-100", quantity: 5, unitPrice: 180.00, totalPrice: 900.00),
        OrderItem(id: "item_013", productName: "UPS Battery Backup 3000VA", productCode: "UPS3K", quantity: 2, unitPrice: 1450.00, totalPrice: 2900.00),

        // Items for del_009 (ORD-2024-301) - Total: $28,500
        OrderItem(id: "item_014", productName: "Research Microscope Pro", productCode: "RMP-2000", quantity: 1, unitPrice: 18500.00, totalPrice: 18500.00),
        OrderItem(id: "item_015", productName: "Lab Centrifuge 15000rpm", productCode: "LC15K", quantity: 2, unitPrice: 3500.00, totalPrice: 7000.00),
        OrderItem(id: "item_016", productName: "Chemical Storage Cabinet", productCode: "CSC-SAFE", quantity: 3, unitPrice: 1000.00, totalPrice: 3000.00),

        // Items for del_013 (ORD-2024-401) - Total: $14,300
        OrderItem(id: "item_017", productName: "Software License Enterprise", productCode: "SLE-2024", quantity: 50, unitPrice: 250.00, totalPrice: 12500.00),
        OrderItem(id: "item_018", productName: "Training Package", productCode: "TP-ADV", quantity: 1, unitPrice: 1800.00, totalPrice: 1800.00)
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
            status: .delivered,
            items: [
                OrderItem(id: "item_001", productName: "Industrial Pump Model X200", productCode: "IPX200", quantity: 5, unitPrice: 2500.00, totalPrice: 12500.00),
                OrderItem(id: "item_002", productName: "Pressure Valve Set", productCode: "PVS-100", quantity: 10, unitPrice: 125.00, totalPrice: 1250.00),
                OrderItem(id: "item_003", productName: "Installation Kit", productCode: "IK-STD", quantity: 2, unitPrice: 1000.00, totalPrice: 2000.00)
            ],
            notes: "Delivered to loading dock. Customer requested installation scheduled for next week."
        ),
        Delivery(
            id: "del_002",
            customerId: "12345",
            date: Calendar.current.date(byAdding: .day, value: -20, to: Date()) ?? Date(),
            total: 22300.00,
            orderNumber: "ORD-2024-102",
            status: .delivered,
            items: [
                OrderItem(id: "item_004", productName: "Heavy Duty Motor 50HP", productCode: "HDM50", quantity: 2, unitPrice: 8500.00, totalPrice: 17000.00),
                OrderItem(id: "item_005", productName: "Control Panel Assembly", productCode: "CPA-200", quantity: 1, unitPrice: 3500.00, totalPrice: 3500.00),
                OrderItem(id: "item_006", productName: "Safety Switch Kit", productCode: "SSK-PRO", quantity: 4, unitPrice: 450.00, totalPrice: 1800.00)
            ],
            notes: "Special handling required for motor installation. Customer very satisfied with delivery timing."
        ),
        Delivery(
            id: "del_003",
            customerId: "12345",
            date: Calendar.current.date(byAdding: .day, value: -35, to: Date()) ?? Date(),
            total: 18950.00,
            orderNumber: "ORD-2024-103",
            status: .delivered,
            items: [
                OrderItem(id: "item_007", productName: "Hydraulic Cylinder 12\"", productCode: "HC12", quantity: 3, unitPrice: 4500.00, totalPrice: 13500.00),
                OrderItem(id: "item_008", productName: "Hydraulic Fluid 55gal", productCode: "HF55", quantity: 8, unitPrice: 275.00, totalPrice: 2200.00),
                OrderItem(id: "item_009", productName: "Maintenance Tools Set", productCode: "MTS-PRO", quantity: 1, unitPrice: 3250.00, totalPrice: 3250.00)
            ],
            notes: "Hydraulic system upgrade completed successfully. Customer training provided on-site."
        ),
        Delivery(
            id: "del_004",
            customerId: "12345",
            date: Calendar.current.date(byAdding: .day, value: -50, to: Date()) ?? Date(),
            total: 12400.00,
            orderNumber: "ORD-2024-104",
            status: .delivered,
            items: [
                OrderItem(id: "item_019", productName: "Conveyor Belt System", productCode: "CBS-300", quantity: 1, unitPrice: 8500.00, totalPrice: 8500.00),
                OrderItem(id: "item_020", productName: "Belt Tensioner Kit", productCode: "BTK-STD", quantity: 2, unitPrice: 650.00, totalPrice: 1300.00),
                OrderItem(id: "item_021", productName: "Maintenance Manual", productCode: "MM-CBS", quantity: 3, unitPrice: 200.00, totalPrice: 600.00),
                OrderItem(id: "item_022", productName: "Spare Parts Kit", productCode: "SPK-CBS", quantity: 1, unitPrice: 2000.00, totalPrice: 2000.00)
            ],
            notes: "Conveyor system installation completed ahead of schedule. Customer requested additional spare parts."
        ),
        Delivery(
            id: "del_005",
            customerId: "12345",
            date: Calendar.current.date(byAdding: .day, value: -65, to: Date()) ?? Date(),
            total: 19800.00,
            orderNumber: "ORD-2024-105",
            status: .delivered,
            items: [
                OrderItem(id: "item_023", productName: "Air Compressor 100HP", productCode: "AC100", quantity: 1, unitPrice: 15000.00, totalPrice: 15000.00),
                OrderItem(id: "item_024", productName: "Air Tank 500gal", productCode: "AT500", quantity: 1, unitPrice: 3200.00, totalPrice: 3200.00),
                OrderItem(id: "item_025", productName: "Pressure Regulator", productCode: "PR-INDUST", quantity: 4, unitPrice: 400.00, totalPrice: 1600.00)
            ],
            notes: "Air compression system upgrade for production line. Installation scheduled for weekend to minimize downtime."
        ),

        // Deliveries for Sarah Johnson (Tech Solutions Inc) - Last 3
        Delivery(
            id: "del_006",
            customerId: "12346",
            date: Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date(),
            total: 8750.00,
            orderNumber: "ORD-2024-201",
            status: .delivered,
            items: [
                OrderItem(id: "item_010", productName: "Server Rack 42U", productCode: "SR42U", quantity: 2, unitPrice: 1200.00, totalPrice: 2400.00),
                OrderItem(id: "item_011", productName: "Network Switch 48-Port", productCode: "NS48P", quantity: 3, unitPrice: 850.00, totalPrice: 2550.00),
                OrderItem(id: "item_012", productName: "Cable Management Kit", productCode: "CMK-100", quantity: 5, unitPrice: 180.00, totalPrice: 900.00),
                OrderItem(id: "item_013", productName: "UPS Battery Backup 3000VA", productCode: "UPS3K", quantity: 2, unitPrice: 1450.00, totalPrice: 2900.00)
            ],
            notes: "Data center expansion equipment delivered. Customer pleased with packaging and condition of items."
        ),
        Delivery(
            id: "del_007",
            customerId: "12346",
            date: Calendar.current.date(byAdding: .day, value: -40, to: Date()) ?? Date(),
            total: 11200.00,
            orderNumber: "ORD-2024-202",
            status: .delivered,
            items: [
                OrderItem(id: "item_026", productName: "Workstation Desktop Pro", productCode: "WDP-2024", quantity: 8, unitPrice: 1200.00, totalPrice: 9600.00),
                OrderItem(id: "item_027", productName: "Monitor 27\" 4K", productCode: "M27-4K", quantity: 8, unitPrice: 200.00, totalPrice: 1600.00)
            ],
            notes: "Office equipment upgrade for development team. All workstations tested and configured on-site."
        ),
        Delivery(
            id: "del_008",
            customerId: "12346",
            date: Calendar.current.date(byAdding: .day, value: -70, to: Date()) ?? Date(),
            total: 6500.00,
            orderNumber: "ORD-2024-203",
            status: .delivered,
            items: [
                OrderItem(id: "item_028", productName: "Security Camera System", productCode: "SCS-PRO", quantity: 1, unitPrice: 4500.00, totalPrice: 4500.00),
                OrderItem(id: "item_029", productName: "Access Control Panel", productCode: "ACP-200", quantity: 1, unitPrice: 1200.00, totalPrice: 1200.00),
                OrderItem(id: "item_030", productName: "Installation Service", productCode: "IS-SEC", quantity: 1, unitPrice: 800.00, totalPrice: 800.00)
            ],
            notes: "Security system installation completed. Customer training provided for system operation."
        ),

        // Deliveries for Lisa Chen (Innovation Labs) - Last 4
        Delivery(
            id: "del_009",
            customerId: "12348",
            date: Calendar.current.date(byAdding: .day, value: -8, to: Date()) ?? Date(),
            total: 28500.00,
            orderNumber: "ORD-2024-301",
            status: .delivered,
            items: [
                OrderItem(id: "item_014", productName: "Research Microscope Pro", productCode: "RMP-2000", quantity: 1, unitPrice: 18500.00, totalPrice: 18500.00),
                OrderItem(id: "item_015", productName: "Lab Centrifuge 15000rpm", productCode: "LC15K", quantity: 2, unitPrice: 3500.00, totalPrice: 7000.00),
                OrderItem(id: "item_016", productName: "Chemical Storage Cabinet", productCode: "CSC-SAFE", quantity: 3, unitPrice: 1000.00, totalPrice: 3000.00)
            ],
            notes: "Laboratory equipment upgrade for research division. All equipment calibrated and certified."
        ),
        Delivery(
            id: "del_010",
            customerId: "12348",
            date: Calendar.current.date(byAdding: .day, value: -25, to: Date()) ?? Date(),
            total: 31200.00,
            orderNumber: "ORD-2024-302",
            status: .delivered,
            items: [
                OrderItem(id: "item_031", productName: "Spectrometer Advanced", productCode: "SA-2024", quantity: 1, unitPrice: 25000.00, totalPrice: 25000.00),
                OrderItem(id: "item_032", productName: "Sample Preparation Kit", productCode: "SPK-ADV", quantity: 2, unitPrice: 1800.00, totalPrice: 3600.00),
                OrderItem(id: "item_033", productName: "Calibration Standards", productCode: "CS-SPEC", quantity: 4, unitPrice: 650.00, totalPrice: 2600.00)
            ],
            notes: "High-precision analytical equipment delivered. Extended warranty and training package included."
        ),
        Delivery(
            id: "del_011",
            customerId: "12348",
            date: Calendar.current.date(byAdding: .day, value: -45, to: Date()) ?? Date(),
            total: 24800.00,
            orderNumber: "ORD-2024-303",
            status: .delivered,
            items: [
                OrderItem(id: "item_034", productName: "Clean Room Equipment", productCode: "CRE-CLASS10", quantity: 1, unitPrice: 18000.00, totalPrice: 18000.00),
                OrderItem(id: "item_035", productName: "HEPA Filter System", productCode: "HFS-ULTRA", quantity: 2, unitPrice: 2200.00, totalPrice: 4400.00),
                OrderItem(id: "item_036", productName: "Air Quality Monitor", productCode: "AQM-PRO", quantity: 3, unitPrice: 800.00, totalPrice: 2400.00)
            ],
            notes: "Clean room facility setup completed. Air quality certification provided with installation."
        ),
        Delivery(
            id: "del_012",
            customerId: "12348",
            date: Calendar.current.date(byAdding: .day, value: -60, to: Date()) ?? Date(),
            total: 33750.00,
            orderNumber: "ORD-2024-304",
            status: .delivered,
            items: [
                OrderItem(id: "item_037", productName: "Electron Microscope SEM", productCode: "EM-SEM-5000", quantity: 1, unitPrice: 28000.00, totalPrice: 28000.00),
                OrderItem(id: "item_038", productName: "Sample Stage Kit", productCode: "SSK-EM", quantity: 1, unitPrice: 3500.00, totalPrice: 3500.00),
                OrderItem(id: "item_039", productName: "Maintenance Contract 3yr", productCode: "MC-EM-3Y", quantity: 1, unitPrice: 2250.00, totalPrice: 2250.00)
            ],
            notes: "Electron microscope installation and commissioning completed. Operator training scheduled for next month."
        ),

        // Deliveries for Robert Wilson (Silicon Valley Dynamics) - Last 2
        Delivery(
            id: "del_013",
            customerId: "12349",
            date: Calendar.current.date(byAdding: .day, value: -18, to: Date()) ?? Date(),
            total: 14300.00,
            orderNumber: "ORD-2024-401",
            status: .delivered,
            items: [
                OrderItem(id: "item_017", productName: "Software License Enterprise", productCode: "SLE-2024", quantity: 50, unitPrice: 250.00, totalPrice: 12500.00),
                OrderItem(id: "item_018", productName: "Training Package", productCode: "TP-ADV", quantity: 1, unitPrice: 1800.00, totalPrice: 1800.00)
            ],
            notes: "Enterprise software deployment completed. All user accounts configured and training materials provided."
        ),
        Delivery(
            id: "del_014",
            customerId: "12349",
            date: Calendar.current.date(byAdding: .day, value: -55, to: Date()) ?? Date(),
            total: 16750.00,
            orderNumber: "ORD-2024-402",
            status: .delivered,
            items: [
                OrderItem(id: "item_040", productName: "Cloud Storage 10TB", productCode: "CS-10TB", quantity: 5, unitPrice: 2800.00, totalPrice: 14000.00),
                OrderItem(id: "item_041", productName: "Backup Solution Pro", productCode: "BSP-2024", quantity: 1, unitPrice: 2750.00, totalPrice: 2750.00)
            ],
            notes: "Cloud infrastructure upgrade completed. Data migration and backup systems fully operational."
        )
    ]
}


