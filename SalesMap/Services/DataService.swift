//
//  DataService.swift
//  SalesMap
//
//  Created by Brandon Lackey on 9/11/25.
//

import Foundation
import Combine
import CoreLocation

class DataService: ObservableObject {
    @Published var customers: [Customer] = []
    @Published var visits: [Visit] = []
    @Published var serviceCalls: [ServiceCall] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let userDefaults = UserDefaults.standard
    private let customersKey = "saved_customers"
    private let visitsKey = "saved_visits"
    private let serviceCallsKey = "saved_service_calls"
    
    init() {
        loadSavedData()
    }
    
    // MARK: - Customer Operations
    func fetchCustomers() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        await MainActor.run {
            // For MVP, use sample data
            if customers.isEmpty {
                customers = Customer.sampleCustomers
                saveCustomers()
            }
            isLoading = false
        }
    }
    
    func getCustomer(by id: String) -> Customer? {
        return customers.first { $0.id == id }
    }
    
    func getCustomersWithinRadius(from location: CLLocation, radiusInMiles: Double) -> [Customer] {
        let radiusInMeters = radiusInMiles * 1609.34 // Convert miles to meters
        
        return customers.filter { customer in
            let customerLocation = CLLocation(latitude: customer.latitude, longitude: customer.longitude)
            let distance = location.distance(from: customerLocation)
            return distance <= radiusInMeters
        }
    }
    
    // MARK: - Visit Operations
    func fetchVisits() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        await MainActor.run {
            // For MVP, use sample data
            if visits.isEmpty {
                visits = Visit.sampleVisits
                saveVisits()
            }
            isLoading = false
        }
    }
    
    func createVisit(_ visit: Visit) async {
        await MainActor.run {
            visits.append(visit)
            saveVisits()
        }
    }
    
    func getVisitsForCustomer(_ customerId: String) -> [Visit] {
        return visits.filter { $0.customerId == customerId }
    }
    
    func getLastVisitForCustomer(_ customerId: String) -> Visit? {
        return visits
            .filter { $0.customerId == customerId }
            .sorted { $0.checkInTime > $1.checkInTime }
            .first
    }

    // MARK: - Service Call Operations
    func addServiceCall(_ serviceCall: ServiceCall) {
        serviceCalls.append(serviceCall)
        saveServiceCalls()
    }

    func getServiceCallsForCustomer(_ customerId: String) -> [ServiceCall] {
        return serviceCalls.filter { $0.customerId == customerId }
    }
    
    // MARK: - Persistence
    private func saveCustomers() {
        if let encoded = try? JSONEncoder().encode(customers) {
            userDefaults.set(encoded, forKey: customersKey)
        }
    }
    
    private func saveVisits() {
        if let encoded = try? JSONEncoder().encode(visits) {
            userDefaults.set(encoded, forKey: visitsKey)
        }
    }

    private func saveServiceCalls() {
        if let encoded = try? JSONEncoder().encode(serviceCalls) {
            userDefaults.set(encoded, forKey: serviceCallsKey)
        }
    }
    
    private func loadSavedData() {
        // Load customers
        if let data = userDefaults.data(forKey: customersKey),
           let savedCustomers = try? JSONDecoder().decode([Customer].self, from: data) {
            customers = savedCustomers
        }
        
        // Load visits
        if let data = userDefaults.data(forKey: visitsKey),
           let savedVisits = try? JSONDecoder().decode([Visit].self, from: data) {
            visits = savedVisits
        }

        // Load service calls
        if let data = userDefaults.data(forKey: serviceCallsKey),
           let savedServiceCalls = try? JSONDecoder().decode([ServiceCall].self, from: data) {
            serviceCalls = savedServiceCalls
        }
    }
}
