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
    @State private var showingDistanceWarning = false

    // Follow-up related states
    @State private var createFollowUp = false
    @State private var followUpDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var followUpNotes = ""
    @State private var followUpPriority: FollowUpPriority = .medium
    
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
                        // Customer Section
                        VStack(alignment: .leading, spacing: 12) {
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

                        // Visit Purpose Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Visit Purpose")
                                .font(.headline)

                            Picker("Purpose", selection: $selectedPurpose) {
                                ForEach(VisitPurpose.allCases, id: \.self) { purpose in
                                    Text(purpose.displayName).tag(purpose)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(Color.brandLight)
                            .cornerRadius(12)
                        }

                        // Notes Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notes")
                                .font(.headline)

                            TextEditor(text: $notes)
                                .frame(minHeight: 100)
                                .padding(8)
                                .background(Color.brandLight)
                                .cornerRadius(12)
                        }

                        // Follow-up Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Follow-up")
                                .font(.headline)

                            VStack(alignment: .leading, spacing: 16) {
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
                                            .padding(8)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.brandLight)
                            .cornerRadius(12)
                        }

                        // Location Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Location")
                                .font(.headline)

                            if let location = locationManager.location {
                                let distanceInMeters = location.distance(from: customer.location)
                                let distanceInMiles = distanceInMeters * 0.000621371 // Convert meters to miles
                                HStack {
                                    Image(systemName: distanceInMeters <= 100 ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                        .foregroundColor(distanceInMeters <= 100 ? .brandPrimary : .brandRed)
                                    Text("Distance: \(String(format: "%.1f", distanceInMiles)) mi from customer")
                                        .font(.caption)
                                }
                            } else {
                                HStack {
                                    Image(systemName: "location.slash")
                                        .foregroundColor(.brandRed)
                                    Text("Location not available")
                                        .font(.caption)
                                }
                            }
                        }
                        .padding()
                        .background(Color.brandLight)
                        .cornerRadius(12)

                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("Check In")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Check In") {
                    Task {
                        await handleCheckInTap()
                    }
                }
                .disabled(isCheckingIn || locationManager.location == nil)
                .tint(.brandPrimary)
            )
            .alert("Location Required", isPresented: $showingLocationError) {
                Button("OK") { }
            } message: {
                Text("Location access is required to check in. Please enable location services and try again.")
            }
            .alert("Distance Warning", isPresented: $showingDistanceWarning) {
                Button("Cancel", role: .cancel) { }
                Button("Check In Anyway") {
                    Task {
                        await performCheckIn()
                    }
                }
            } message: {
                if let location = locationManager.location {
                    let distanceInMeters = location.distance(from: customer.location)
                    let distanceInMiles = distanceInMeters * 0.000621371
                    Text("You appear to be \(String(format: "%.1f", distanceInMiles)) miles away from \(customer.company). Are you sure you want to check in from this location?")
                } else {
                    Text("Unable to determine your distance from the customer.")
                }
            }
        }
    }

    private func handleCheckInTap() async {
        guard let currentLocation = locationManager.location else {
            showingLocationError = true
            return
        }

        let distanceInMeters = currentLocation.distance(from: customer.location)
        let distanceInMiles = distanceInMeters * 0.000621371

        // Show warning if more than 3 miles away
        if distanceInMiles > 3.0 {
            showingDistanceWarning = true
        } else {
            await performCheckIn()
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
