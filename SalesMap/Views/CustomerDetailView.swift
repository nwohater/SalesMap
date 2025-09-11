//
//  CustomerDetailView.swift
//  SalesMap
//
//  Created by Brandon Lackey on 9/11/25.
//

import SwiftUI
import MapKit

struct CustomerDetailView: View {
    let customer: Customer
    @EnvironmentObject var dataService: DataService
    @Environment(\.dismiss) private var dismiss
    @State private var showingCheckIn = false
    @State private var showingServiceCall = false
    @State private var showingDeliveryHistory = false
    
    var recentVisits: [Visit] {
        dataService.getVisitsForCustomer(customer.id)
            .sorted { $0.checkInTime > $1.checkInTime }
            .prefix(3)
            .map { $0 }
    }

    var recentServiceCalls: [ServiceCall] {
        dataService.getServiceCallsForCustomer(customer.id)
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(3)
            .map { $0 }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(customer.company)
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                            TierBadge(tier: customer.tier)
                        }

                        Text("Contact: \(customer.name)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Contact Information
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Contact Information")
                            .font(.headline)
                        
                        ContactRow(icon: "location", text: customer.address)
                        ContactRow(icon: "phone", text: customer.phone)
                        ContactRow(icon: "envelope", text: customer.email)
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            showingCheckIn = true
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle")
                                Text("Check In")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            openMapsForDirections()
                        }) {
                            HStack {
                                Image(systemName: "location.circle")
                                Text("Get Directions")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            callCustomer()
                        }) {
                            HStack {
                                Image(systemName: "phone.circle")
                                Text("Call")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }

                        Button(action: {
                            showingServiceCall = true
                        }) {
                            HStack {
                                Image(systemName: "wrench.and.screwdriver")
                                Text("Open Service Call")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    
                    // Recent Visits
                    if !recentVisits.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Visits")
                                .font(.headline)

                            ForEach(recentVisits) { visit in
                                VisitRow(visit: visit)
                            }
                        }
                    }

                    // Recent Service
                    if !recentServiceCalls.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Service")
                                .font(.headline)

                            ForEach(recentServiceCalls) { serviceCall in
                                ServiceCallRow(serviceCall: serviceCall)
                            }
                        }
                    }

                    // Sales Information - Tappable
                    Button(action: {
                        showingDeliveryHistory = true
                    }) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Sales Information")
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            HStack {
                                Text("Total Revenue:")
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("$\(Int(customer.totalRevenue).formatted())")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }

                            if let lastPurchase = customer.lastPurchase {
                                HStack {
                                    Text("Last Purchase:")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text(lastPurchase, style: .date)
                                        .foregroundColor(.secondary)
                                }
                            }

                            if let lastContact = customer.lastContact {
                                HStack {
                                    Text("Last Contact:")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text(lastContact, style: .date)
                                        .foregroundColor(.secondary)
                                }
                            }

                            // Hint text
                            HStack {
                                Text("Tap to view delivery history")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                Spacer()
                            }
                            .padding(.top, 4)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
            }
            .navigationTitle("Customer Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showingCheckIn) {
                CheckInView(customer: customer)
            }
            .sheet(isPresented: $showingServiceCall) {
                ServiceCallView(customer: customer)
            }
            .sheet(isPresented: $showingDeliveryHistory) {
                DeliveryHistoryView(customer: customer)
            }
        }
    }
    
    private func openMapsForDirections() {
        let placemark = MKPlacemark(coordinate: customer.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = customer.company
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    private func callCustomer() {
        let phoneNumber = customer.phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if let url = URL(string: "tel://\(phoneNumber)") {
            UIApplication.shared.open(url)
        }
    }
}

struct TierBadge: View {
    let tier: String
    
    var body: some View {
        Text(tier)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(colorForTier)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
    
    private var colorForTier: Color {
        switch tier.lowercased() {
        case "gold":
            return .yellow
        case "silver":
            return .gray
        case "bronze":
            return .orange
        default:
            return .blue
        }
    }
}

struct ContactRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            Text(text)
                .foregroundColor(.primary)
        }
    }
}

struct VisitRow: View {
    let visit: Visit
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(visit.purpose.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(visit.checkInTime, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if let notes = visit.notes, !notes.isEmpty {
                Image(systemName: "note.text")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct ServiceCallRow: View {
    let serviceCall: ServiceCall

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(serviceCall.problemDescription)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                Text(serviceCall.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                PriorityBadge(priority: serviceCall.priority)
                Text(serviceCall.status.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct PriorityBadge: View {
    let priority: ServiceCallPriority

    var body: some View {
        Text(priority.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(priority.color.opacity(0.2))
            .foregroundColor(priority.color)
            .cornerRadius(4)
    }
}

#Preview {
    CustomerDetailView(customer: Customer.sampleCustomers[0])
        .environmentObject(DataService())
}
