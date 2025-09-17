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
    @State private var selectedVisit: Visit?
    @State private var selectedServiceCall: ServiceCall?
    
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
            ZStack {
                LinearGradient(
                    colors: [
                        Color.brandPrimary.opacity(0.18),
                        Color.brandDarkBlue.opacity(0.16),
                        Color.brandBackground
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                RadialGradient(
                    colors: [
                        Color.brandDarkBlue.opacity(0.14),
                        Color.clear
                    ],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: 400
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text(customer.company)
                                .font(.title2)
                                .fontWeight(.bold)

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
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.brandPrimary)
                            
                            Button(action: {
                                openMapsForDirections()
                            }) {
                                HStack {
                                    Image(systemName: "location.circle")
                                    Text("Get Directions")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.brandSecondary)
                            
                            Button(action: {
                                callCustomer()
                            }) {
                                HStack {
                                    Image(systemName: "phone.circle")
                                    Text("Call")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.brandBlack)

                            Button(action: {
                                showingServiceCall = true
                            }) {
                                HStack {
                                    Image(systemName: "wrench.and.screwdriver")
                                    Text("Open Service Call")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.brandRed)
                        }
                        
                        // Recent Visits
                        if !recentVisits.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recent Visits")
                                    .font(.headline)

                                ForEach(recentVisits) { visit in
                                    VisitRow(visit: visit)
                                        .onTapGesture {
                                            selectedVisit = visit
                                        }
                                }
                            }
                        }

                        // Recent Service
                        if !recentServiceCalls.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recent Service")
                                    .font(.headline)

                                ForEach(recentServiceCalls) { serviceCall in
                                    ServiceCallRow(serviceCall: serviceCall) {
                                        selectedServiceCall = serviceCall
                                    }
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
                                        .foregroundColor(.brandPrimary)
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
            }
            .navigationTitle("Customer Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Check In") {
                        showingCheckIn = true
                    }
                    .foregroundColor(.brandPrimary)
                    .fontWeight(.semibold)
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
            .sheet(item: $selectedVisit) { visit in
                VisitDetailSheet(visit: visit, customer: customer)
            }
            .sheet(item: $selectedServiceCall) { serviceCall in
                ServiceDetailView(serviceCall: serviceCall)
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



struct ContactRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.brandPrimary)
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
            HStack(spacing: 8) {
                if let notes = visit.notes, !notes.isEmpty {
                    Image(systemName: "note.text")
                        .foregroundColor(.brandPrimary)
                }
                Image(systemName: "chevron.right")
                    .foregroundColor(.brandPrimary)
                    .font(.caption)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.brandLight)
        .cornerRadius(8)
    }
}

struct ServiceCallRow: View {
    let serviceCall: ServiceCall
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(serviceCall.problemDescription)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .foregroundColor(.primary)
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

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.brandLight)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
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

// MARK: - Visit Detail Sheet
struct VisitDetailSheet: View {
    let visit: Visit
    let customer: Customer
    @EnvironmentObject var dataService: DataService
    @Environment(\.dismiss) private var dismiss
    @State private var showingCreateFollowUp = false

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.brandPrimary.opacity(0.18),
                        Color.brandDarkBlue.opacity(0.16),
                        Color.brandBackground
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                RadialGradient(
                    colors: [
                        Color.brandDarkBlue.opacity(0.14),
                        Color.clear
                    ],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: 400
                )
                .ignoresSafeArea()

                ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Customer Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Customer")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(customer.name)
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text(customer.company)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.brandLight)
                        .cornerRadius(12)
                    }

                    // Visit Details
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Visit Details")
                            .font(.headline)

                        VStack(spacing: 12) {
                            // Purpose and Date
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Purpose")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(visit.purpose.displayName)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.brandPrimary.opacity(0.1))
                                        .foregroundColor(.brandPrimary)
                                        .cornerRadius(8)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Check-in Time")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(visit.checkInTime, style: .date)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text(visit.checkInTime, style: .time)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }

                            // Check-out time if available
                            if let checkOutTime = visit.checkOutTime {
                                HStack {
                                    Text("Check-out Time:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text(checkOutTime, style: .date)
                                            .font(.caption)
                                        Text(checkOutTime, style: .time)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }

                            // Notes
                            if let notes = visit.notes, !notes.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Notes")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text(notes)
                                        .font(.body)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                }
                            } else {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Notes")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text("No notes recorded for this visit")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .italic()
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }

                    // Create Follow-up Button
                    Button(action: {
                        showingCreateFollowUp = true
                    }) {
                        HStack {
                            Image(systemName: "bell.badge.fill")
                            Text("Create Follow-up")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.brandPrimary)
                    .padding(.top, 20)
                }
                .padding()
            }
            }
            .navigationTitle("Visit Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showingCreateFollowUp) {
                CreateFollowUpFromVisitSheet(
                    visit: visit,
                    customer: customer,
                    onFollowUpCreated: {
                        dismiss()
                    }
                )
            }
        }
    }
}

// MARK: - Create Follow-up From Visit Sheet
struct CreateFollowUpFromVisitSheet: View {
    let visit: Visit
    let customer: Customer
    let onFollowUpCreated: () -> Void

    @EnvironmentObject var dataService: DataService
    @Environment(\.dismiss) private var dismiss

    @State private var followUpDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var followUpNotes = ""
    @State private var followUpPriority: FollowUpPriority = .medium
    @State private var isCreating = false

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.brandPrimary.opacity(0.18),
                        Color.brandDarkBlue.opacity(0.16),
                        Color.brandBackground
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                RadialGradient(
                    colors: [
                        Color.brandDarkBlue.opacity(0.14),
                        Color.clear
                    ],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: 400
                )
                .ignoresSafeArea()

                ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Create Follow-up")
                        .font(.title2)
                        .fontWeight(.bold)

                    // Visit Context
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Based on Visit")
                            .font(.headline)

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
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }

                    // Customer Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Customer")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(customer.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(customer.company)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }

                    // Follow-up Details
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Follow-up Details")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Follow-up Date")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            DatePicker("", selection: $followUpDate, in: Date()..., displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Priority")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Picker("Priority", selection: $followUpPriority) {
                                ForEach(FollowUpPriority.allCases, id: \.self) { priority in
                                    Text(priority.displayName).tag(priority)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            TextEditor(text: $followUpNotes)
                                .frame(minHeight: 100)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                    }

                    Button(action: createFollowUp) {
                        HStack {
                            if isCreating {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "bell.badge.fill")
                            }
                            Text(isCreating ? "Creating..." : "Create Follow-up")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(isCreating ? .gray : .brandPrimary)
                    .disabled(isCreating)
                    .padding(.top, 20)
                }
                .padding()
            }
            }
            .navigationTitle("New Follow-up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func createFollowUp() {
        isCreating = true

        let followUp = FollowUp(
            id: UUID().uuidString,
            customerId: customer.id,
            userId: "rep_456", // TODO: Get from auth service
            followUpDate: followUpDate,
            notes: followUpNotes.isEmpty ? nil : followUpNotes,
            priority: followUpPriority,
            isCompleted: false,
            createdAt: Date(),
            completedAt: nil,
            completionNotes: nil,
            relatedVisitId: visit.id
        )

        Task {
            await dataService.createFollowUp(followUp)
            await MainActor.run {
                isCreating = false
                onFollowUpCreated()
                dismiss()
            }
        }
    }
}

#Preview {
    CustomerDetailView(customer: Customer.sampleCustomers[0])
        .environmentObject(DataService())
}
