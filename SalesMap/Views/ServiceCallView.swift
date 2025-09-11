//
//  ServiceCallView.swift
//  SalesMap
//
//  Created by Brandon Lackey on 9/11/25.
//

import SwiftUI

struct ServiceCallView: View {
    let customer: Customer
    @EnvironmentObject var dataService: DataService
    @Environment(\.dismiss) private var dismiss
    
    @State private var problemDescription = ""
    @State private var priority: ServiceCallPriority = .medium

    @State private var isSubmitting = false
    @State private var showingSuccess = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Service Call for")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Text(customer.company)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Contact: \(customer.name)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 10)
                    

                    
                    // Priority Level
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Priority Level")
                            .font(.headline)
                        
                        Picker("Priority", selection: $priority) {
                            ForEach(ServiceCallPriority.allCases, id: \.self) { priority in
                                HStack {
                                    Circle()
                                        .fill(priority.color)
                                        .frame(width: 12, height: 12)
                                    Text(priority.displayName)
                                }
                                .tag(priority)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Problem Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Problem Description")
                            .font(.headline)
                        
                        TextEditor(text: $problemDescription)
                            .frame(minHeight: 120)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                        
                        if problemDescription.isEmpty {
                            Text("Describe the issue the customer is experiencing...")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    
                    // Submit Button
                    Button(action: {
                        submitServiceCall()
                    }) {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "paperplane.fill")
                            }
                            Text(isSubmitting ? "Submitting..." : "Submit Service Call")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canSubmit ? Color.red : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(!canSubmit || isSubmitting)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Service Call")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Service Call Submitted", isPresented: $showingSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("Your service call has been submitted successfully. The support team will be notified.")
            }
        }
    }
    
    private var canSubmit: Bool {
        !problemDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func submitServiceCall() {
        guard canSubmit else { return }
        
        isSubmitting = true
        
        // Create service call record
        let serviceCall = ServiceCall(
            id: UUID().uuidString,
            customerId: customer.id,
            customerName: customer.name,
            customerCompany: customer.company,
            category: .technical, // Default category since we removed the picker
            priority: priority,
            problemDescription: problemDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            status: .open,
            createdAt: Date(),
            assignedTo: nil,
            resolvedAt: nil
        )
        
        // Simulate API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dataService.addServiceCall(serviceCall)
            isSubmitting = false
            showingSuccess = true
        }
    }
}

enum ServiceCallPriority: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"
    
    var displayName: String {
        return self.rawValue
    }
    
    var color: Color {
        switch self {
        case .low:
            return .green
        case .medium:
            return .yellow
        case .high:
            return .orange
        case .urgent:
            return .red
        }
    }
}

enum ServiceCallCategory: String, CaseIterable, Codable {
    case technical = "Technical"
    case billing = "Billing"
    case delivery = "Delivery"
    case product = "Product"
    
    var displayName: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .technical:
            return "wrench.and.screwdriver"
        case .billing:
            return "dollarsign.circle"
        case .delivery:
            return "truck"
        case .product:
            return "cube.box"
        }
    }
}

enum ServiceCallStatus: String, Codable {
    case open = "Open"
    case inProgress = "In Progress"
    case resolved = "Resolved"
    case closed = "Closed"
}

struct ServiceCall: Identifiable, Codable {
    let id: String
    let customerId: String
    let customerName: String
    let customerCompany: String
    let category: ServiceCallCategory
    let priority: ServiceCallPriority
    let problemDescription: String
    let status: ServiceCallStatus
    let createdAt: Date
    let assignedTo: String?
    let resolvedAt: Date?
}

#Preview {
    ServiceCallView(customer: Customer.sampleCustomers[0])
        .environmentObject(DataService())
}
