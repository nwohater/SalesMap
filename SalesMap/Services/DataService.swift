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
    @Published var deliveries: [Delivery] = []
    @Published var followUps: [FollowUp] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let userDefaults = UserDefaults.standard
    private let customersKey = "saved_customers"
    private let visitsKey = "saved_visits"
    private let serviceCallsKey = "saved_service_calls"
    private let deliveriesKey = "saved_deliveries"
    private let followUpsKey = "saved_follow_ups"
    
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

    // MARK: - Delivery Operations
    func fetchDeliveries() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        await MainActor.run {
            // For MVP, use sample data
            if deliveries.isEmpty {
                deliveries = Delivery.sampleDeliveries
                saveDeliveries()
            }
            isLoading = false
        }
    }

    func getDeliveriesForCustomer(_ customerId: String) -> [Delivery] {
        return deliveries.filter { $0.customerId == customerId }
    }

    // MARK: - Follow-up Operations
    func fetchFollowUps() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        // Simulate network delay
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        await MainActor.run {
            // For MVP, use sample data
            if followUps.isEmpty {
                followUps = FollowUp.sampleFollowUps
                saveFollowUps()
            }
            isLoading = false
        }
    }

    func createFollowUp(_ followUp: FollowUp) async {
        await MainActor.run {
            followUps.append(followUp)
            saveFollowUps()
        }
    }

    func updateFollowUp(_ followUp: FollowUp) async {
        await MainActor.run {
            if let index = followUps.firstIndex(where: { $0.id == followUp.id }) {
                followUps[index] = followUp
                saveFollowUps()
            }
        }
    }

    func completeFollowUp(_ followUpId: String, completionNotes: String? = nil) async {
        await MainActor.run {
            if let index = followUps.firstIndex(where: { $0.id == followUpId }) {
                let updatedFollowUp = FollowUp(
                    id: followUps[index].id,
                    customerId: followUps[index].customerId,
                    userId: followUps[index].userId,
                    followUpDate: followUps[index].followUpDate,
                    notes: followUps[index].notes,
                    priority: followUps[index].priority,
                    isCompleted: true,
                    createdAt: followUps[index].createdAt,
                    completedAt: Date(),
                    completionNotes: completionNotes,
                    relatedVisitId: followUps[index].relatedVisitId
                )
                followUps[index] = updatedFollowUp
                saveFollowUps()
            }
        }
    }

    func getFollowUpsForCustomer(_ customerId: String) -> [FollowUp] {
        return followUps.filter { $0.customerId == customerId && !$0.isCompleted }
    }

    func getPendingFollowUps() -> [FollowUp] {
        return followUps.filter { !$0.isCompleted }
            .sorted { followUp1, followUp2 in
                // Sort by priority first, then by date
                if followUp1.priority.sortOrder != followUp2.priority.sortOrder {
                    return followUp1.priority.sortOrder < followUp2.priority.sortOrder
                }
                return followUp1.followUpDate < followUp2.followUpDate
            }
    }

    func getOverdueFollowUps() -> [FollowUp] {
        let now = Date()
        return followUps.filter { !$0.isCompleted && $0.followUpDate < now }
            .sorted { $0.followUpDate < $1.followUpDate }
    }

    func getUrgentFollowUps() -> [FollowUp] {
        let calendar = Calendar.current
        let now = Date()
        let endOfToday = calendar.dateInterval(of: .day, for: now)?.end ?? now

        return followUps.filter { !$0.isCompleted && $0.followUpDate <= endOfToday }
            .sorted { $0.followUpDate < $1.followUpDate }
    }

    func completeAndCreateNewFollowUp(
        currentFollowUpId: String,
        completionNotes: String?,
        newFollowUpDate: Date,
        newNotes: String?,
        newPriority: FollowUpPriority
    ) async {
        await MainActor.run {
            // Complete the current follow-up
            if let index = followUps.firstIndex(where: { $0.id == currentFollowUpId }) {
                let currentFollowUp = followUps[index]
                let completedFollowUp = FollowUp(
                    id: currentFollowUp.id,
                    customerId: currentFollowUp.customerId,
                    userId: currentFollowUp.userId,
                    followUpDate: currentFollowUp.followUpDate,
                    notes: currentFollowUp.notes,
                    priority: currentFollowUp.priority,
                    isCompleted: true,
                    createdAt: currentFollowUp.createdAt,
                    completedAt: Date(),
                    completionNotes: completionNotes,
                    relatedVisitId: currentFollowUp.relatedVisitId
                )
                followUps[index] = completedFollowUp

                // Create new follow-up
                let newFollowUp = FollowUp(
                    id: UUID().uuidString,
                    customerId: currentFollowUp.customerId,
                    userId: currentFollowUp.userId,
                    followUpDate: newFollowUpDate,
                    notes: newNotes,
                    priority: newPriority,
                    isCompleted: false,
                    createdAt: Date(),
                    completedAt: nil,
                    completionNotes: nil,
                    relatedVisitId: nil
                )
                followUps.append(newFollowUp)
                saveFollowUps()
            }
        }
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

    private func saveDeliveries() {
        if let encoded = try? JSONEncoder().encode(deliveries) {
            userDefaults.set(encoded, forKey: deliveriesKey)
        }
    }

    private func saveFollowUps() {
        if let encoded = try? JSONEncoder().encode(followUps) {
            userDefaults.set(encoded, forKey: followUpsKey)
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

        // Load deliveries
        if let data = userDefaults.data(forKey: deliveriesKey),
           let savedDeliveries = try? JSONDecoder().decode([Delivery].self, from: data) {
            deliveries = savedDeliveries
        }

        // Load follow-ups
        if let data = userDefaults.data(forKey: followUpsKey),
           let savedFollowUps = try? JSONDecoder().decode([FollowUp].self, from: data) {
            followUps = savedFollowUps
        }
    }
}
