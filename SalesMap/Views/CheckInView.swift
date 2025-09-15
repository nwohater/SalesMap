//
//  CheckInView.swift
//  SalesMap
//
//  Created by Brandon Lackey on 9/11/25.
//

import SwiftUI
import CoreLocation

struct CheckInView: View {
    let customer: Customer
    @EnvironmentObject var dataService: DataService
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPurpose: VisitPurpose = .salesCall
    @State private var notes: String = ""
    @State private var isCheckingIn = false
    @State private var showingLocationError = false

    // Follow-up related states
    @State private var createFollowUp = false
    @State private var followUpDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var followUpNotes = ""
    @State private var followUpPriority: FollowUpPriority = .medium
    
    var body: some View {
        NavigationView {
            Form {
                Section("Customer") {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(customer.name)
                                .font(.headline)
                            Text(customer.company)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Visit Purpose") {
                    Picker("Purpose", selection: $selectedPurpose) {
                        ForEach(VisitPurpose.allCases, id: \.self) { purpose in
                            Text(purpose.displayName).tag(purpose)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }

                Section("Follow-up") {
                    Toggle("Create follow-up reminder", isOn: $createFollowUp)

                    if createFollowUp {
                        DatePicker("Follow-up date", selection: $followUpDate, in: Date()..., displayedComponents: .date)

                        Picker("Priority", selection: $followUpPriority) {
                            ForEach(FollowUpPriority.allCases, id: \.self) { priority in
                                Text(priority.displayName).tag(priority)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Follow-up notes")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            TextEditor(text: $followUpNotes)
                                .frame(minHeight: 60)
                        }
                    }
                }
                
                Section("Location") {
                    if let location = locationManager.location {
                        let distance = location.distance(from: customer.location)
                        HStack {
                            Image(systemName: distance <= 100 ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                .foregroundColor(distance <= 100 ? .green : .orange)
                            Text("Distance: \(Int(distance))m from customer")
                                .font(.caption)
                        }
                    } else {
                        HStack {
                            Image(systemName: "location.slash")
                                .foregroundColor(.red)
                            Text("Location not available")
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("Check In")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Check In") {
                    Task {
                        await performCheckIn()
                    }
                }
                .disabled(isCheckingIn || locationManager.location == nil)
            )
            .alert("Location Required", isPresented: $showingLocationError) {
                Button("OK") { }
            } message: {
                Text("Location access is required to check in. Please enable location services and try again.")
            }
        }
    }
    
    private func performCheckIn() async {
        guard let currentLocation = locationManager.location else {
            showingLocationError = true
            return
        }
        
        isCheckingIn = true
        
        let visit = Visit(
            id: "visit_\(UUID().uuidString)",
            customerId: customer.id,
            userId: "rep_456", // TODO: Get from auth service
            purpose: selectedPurpose,
            notes: notes.isEmpty ? nil : notes,
            checkInTime: Date(),
            checkOutTime: nil,
            location: VisitLocation(
                latitude: currentLocation.coordinate.latitude,
                longitude: currentLocation.coordinate.longitude
            ),
            photos: nil
        )
        
        await dataService.createVisit(visit)

        // Create follow-up if requested
        if createFollowUp {
            let followUp = FollowUp(
                id: "followup_\(UUID().uuidString)",
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

            await dataService.createFollowUp(followUp)
        }

        isCheckingIn = false
        dismiss()
    }
}

#Preview {
    CheckInView(customer: Customer.sampleCustomers[0])
        .environmentObject(DataService())
        .environmentObject(LocationManager())
}
