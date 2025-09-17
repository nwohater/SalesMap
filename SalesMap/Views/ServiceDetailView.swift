//
//  ServiceDetailView.swift
//  SalesMap
//
//  Created by Brandon Lackey on 9/17/25.
//

import SwiftUI

struct ServiceDetailView: View {
    let serviceCall: ServiceCall
    @Environment(\.dismiss) private var dismiss
    
    // Mock data for demonstration - will be replaced with API calls later
    @State private var estimatedCompletionDate = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
    @State private var assignedTechnician = "Mike Rodriguez"
    @State private var technicianPhone = "+1-555-0199"
    @State private var lastUpdate = Calendar.current.date(byAdding: .hour, value: -4, to: Date()) ?? Date()
    @State private var statusNotes = "Parts ordered and expected to arrive tomorrow. Technician will contact customer to schedule installation."
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
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
                        // Service Call Header
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Service Call Details")
                                .font(.headline)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("ID:")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text(serviceCall.id.prefix(8).uppercased())
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    PriorityBadge(priority: serviceCall.priority)
                                }
                                
                                HStack {
                                    Text("Status:")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    ServiceStatusBadge(status: serviceCall.status)
                                    Spacer()
                                }
                                
                                HStack {
                                    Text("Created:")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text(serviceCall.createdAt, style: .date)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                        .background(Color.brandLight)
                        .cornerRadius(12)
                        
                        // Customer Information
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Customer")
                                .font(.headline)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(serviceCall.customerName)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Text(serviceCall.customerCompany)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.brandLight)
                        .cornerRadius(12)
                        
                        // Problem Description
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Issue Description")
                                .font(.headline)
                            
                            Text(serviceCall.problemDescription)
                                .font(.body)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding()
                        .background(Color.brandLight)
                        .cornerRadius(12)
                        
                        // Service Status & ETA
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Service Information")
                                .font(.headline)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Estimated Completion")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text(estimatedCompletionDate, style: .date)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("Category")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        HStack {
                                            Image(systemName: serviceCall.category.icon)
                                                .foregroundColor(.brandPrimary)
                                            Text(serviceCall.category.displayName)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                
                                Divider()
                                
                                if let assignedTo = serviceCall.assignedTo {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Assigned Technician")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text(assignedTo)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                } else {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Assigned Technician")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text(assignedTechnician)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        Button(action: {
                                            if let url = URL(string: "tel:\(technicianPhone)") {
                                                UIApplication.shared.open(url)
                                            }
                                        }) {
                                            HStack {
                                                Image(systemName: "phone.fill")
                                                Text(technicianPhone)
                                            }
                                            .font(.caption)
                                            .foregroundColor(.brandPrimary)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.brandLight)
                        .cornerRadius(12)
                        
                        // Latest Update
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Latest Update")
                                .font(.headline)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Last Updated:")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text(lastUpdate, style: .relative)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                
                                Text(statusNotes)
                                    .font(.body)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding()
                        .background(Color.brandLight)
                        .cornerRadius(12)
                        
                        // Refresh Button
                        Button(action: {
                            refreshServiceData()
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "arrow.clockwise")
                                }
                                Text("Refresh Status")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.brandPrimary)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(isLoading)
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("Service Call")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    dismiss()
                }
                .tint(.brandPrimary)
            )
        }
    }
    
    private func refreshServiceData() {
        isLoading = true
        
        // Simulate API call to get latest service status
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Update with mock data - in real app this would be API response
            lastUpdate = Date()
            statusNotes = "Technician has arrived on-site and is beginning diagnostic work. Customer will be updated within 2 hours."
            isLoading = false
        }
    }
}

struct ServiceStatusBadge: View {
    let status: ServiceCallStatus

    var body: some View {
        Text(status.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(6)
    }

    private var statusColor: Color {
        switch status {
        case .open:
            return .brandRed
        case .inProgress:
            return .brandPrimary
        case .resolved:
            return .brandSuccess
        case .closed:
            return .brandSecondary
        }
    }
}

#Preview {
    ServiceDetailView(serviceCall: ServiceCall(
        id: "SC-2024-001",
        customerId: "12345",
        customerName: "John Smith",
        customerCompany: "ABC Manufacturing",
        category: .technical,
        priority: .high,
        problemDescription: "Industrial pump making unusual noise and vibrating excessively. Production line affected.",
        status: .inProgress,
        createdAt: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
        assignedTo: nil,
        resolvedAt: nil
    ))
}
