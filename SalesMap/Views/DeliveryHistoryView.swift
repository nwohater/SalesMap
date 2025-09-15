//
//  DeliveryHistoryView.swift
//  SalesMap
//
//  Created by Brandon Lackey on 9/11/25.
//

import SwiftUI

struct DeliveryHistoryView: View {
    let customer: Customer
    @EnvironmentObject var dataService: DataService
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDelivery: Delivery?
    
    var recentDeliveries: [Delivery] {
        dataService.getDeliveriesForCustomer(customer.id)
            .sorted { $0.date > $1.date }
            .prefix(5) // Show only last 5 deliveries
            .map { $0 }
    }
    
    var totalDeliveryValue: Double {
        recentDeliveries.reduce(0) { $0 + $1.total }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header with customer info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(customer.company)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Contact: \(customer.name)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(customer.address)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Summary section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Delivery Summary")
                            .font(.headline)
                        
                        HStack {
                            Text("Total Deliveries:")
                            Spacer()
                            Text("\(recentDeliveries.count)")
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text("Total Value:")
                            Spacer()
                            Text("$\(Int(totalDeliveryValue).formatted())")
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                        
                        if let lastDelivery = recentDeliveries.first {
                            HStack {
                                Text("Last Delivery:")
                                Spacer()
                                Text(lastDelivery.date, style: .date)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    
                    // Delivery history list
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Deliveries (Last 5)")
                            .font(.headline)
                        
                        if recentDeliveries.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "shippingbox")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary)
                                
                                Text("No delivery history")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("No deliveries found for this customer")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(recentDeliveries) { delivery in
                                    DeliveryRow(delivery: delivery) {
                                        selectedDelivery = delivery
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Delivery History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedDelivery) { delivery in
                DeliveryDetailView(delivery: delivery, customer: customer)
            }
        }
    }
}

struct DeliveryRow: View {
    let delivery: Delivery
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(delivery.orderNumber)
                            .font(.headline)
                            .fontWeight(.semibold)

                        Text(delivery.date, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("$\(Int(delivery.total).formatted())")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        StatusBadge(status: delivery.status)
                    }
                }

                // Add hint text for tapping
                HStack {
                    Text("Tap to view items and invoice details")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatusBadge: View {
    let status: DeliveryStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(6)
    }
    
    private var backgroundColor: Color {
        switch status {
        case .delivered:
            return .brandSuccess
        case .pending:
            return .brandSecondary
        case .cancelled:
            return .brandRed
        }
    }
}

#Preview {
    DeliveryHistoryView(customer: Customer.sampleCustomers[0])
        .environmentObject(DataService())
}
