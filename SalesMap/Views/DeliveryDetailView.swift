//
//  DeliveryDetailView.swift
//  SalesMap
//
//  Created by Brandon Lackey on 9/12/25.
//

import SwiftUI

struct DeliveryDetailView: View {
    let delivery: Delivery
    let customer: Customer
    @Environment(\.dismiss) private var dismiss
    
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
                        // Header with delivery info
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(delivery.orderNumber)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                StatusBadge(status: delivery.status)
                            }
                            
                            HStack {
                                Text("Delivery Date:")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(delivery.date, style: .date)
                                    .fontWeight(.medium)
                            }
                            
                            HStack {
                                Text("Customer:")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(customer.company)
                                    .fontWeight(.medium)
                            }
                            
                            HStack {
                                Text("Total Amount:")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("$\(Int(delivery.total).formatted())")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Items section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Items (\(delivery.items.count))")
                                .font(.headline)
                            
                            LazyVStack(spacing: 12) {
                                ForEach(delivery.items) { item in
                                    OrderItemRow(item: item)
                                }
                            }
                        }
                        
                        // Invoice summary
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Invoice Summary")
                                .font(.headline)
                            
                            VStack(spacing: 8) {
                                ForEach(delivery.items) { item in
                                    HStack {
                                        Text("\(item.quantity)x \(item.productCode)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text(item.formattedTotalPrice)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                }
                                
                                Divider()
                                
                                HStack {
                                    Text("Total")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                    Spacer()
                                    Text("$\(Int(delivery.total).formatted())")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        }
                        
                        // Notes section
                        if let notes = delivery.notes, !notes.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Delivery Notes")
                                    .font(.headline)
                                
                                Text(notes)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Delivery Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct OrderItemRow: View {
    let item: OrderItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.productName)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Code: \(item.productCode)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Qty: \(item.quantity)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(item.formattedUnitPrice)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Text("Total:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(item.formattedTotalPrice)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    DeliveryDetailView(
        delivery: Delivery.sampleDeliveries[0],
        customer: Customer.sampleCustomers[0]
    )
}
