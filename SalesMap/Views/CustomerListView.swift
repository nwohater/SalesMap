//
//  CustomerListView.swift
//  SalesMap
//
//  Created by Brandon Lackey on 9/11/25.
//

import SwiftUI

enum CustomerSortOption: String, CaseIterable {
    case name = "Name"
    case company = "Company"
    case lastContact = "Last Contact"
    case distance = "Distance"
}

struct CustomerListView: View {
    @EnvironmentObject var dataService: DataService
    @EnvironmentObject var locationManager: LocationManager
    @State private var searchText = ""
    @State private var selectedCustomer: Customer?
    @State private var showingFilters = false
    @State private var selectedSort: CustomerSortOption = .distance
    @State private var showRecentVisitsOnly = false

    var filteredAndSortedCustomers: [Customer] {
        var customers = dataService.customers

        // Apply text search filter
        if !searchText.isEmpty {
            customers = customers.filter { customer in
                customer.name.localizedCaseInsensitiveContains(searchText) ||
                customer.company.localizedCaseInsensitiveContains(searchText) ||
                customer.address.localizedCaseInsensitiveContains(searchText) ||
                customer.email.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Apply recent visits filter
        if showRecentVisitsOnly {
            let recentCustomerIds = Set(dataService.visits
                .filter { Calendar.current.isDate($0.checkInTime, inSameDayAs: Date()) }
                .map { $0.customerId })
            customers = customers.filter { recentCustomerIds.contains($0.id) }
        }

        // Apply sorting
        switch selectedSort {
        case .name:
            customers.sort { $0.name < $1.name }
        case .company:
            customers.sort { $0.company < $1.company }
        case .lastContact:
            customers.sort {
                ($0.lastContact ?? Date.distantPast) > ($1.lastContact ?? Date.distantPast)
            }
        case .distance:
            if let currentLocation = locationManager.location {
                customers.sort {
                    currentLocation.distance(from: $0.location) <
                    currentLocation.distance(from: $1.location)
                }
            }
        }

        return customers
    }



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

                VStack(spacing: 0) {
                    // Filter and Sort Controls
                    if showingFilters {
                        FilterControlsView(
                            selectedSort: $selectedSort,
                            showRecentVisitsOnly: $showRecentVisitsOnly
                        )
                        .padding()
                        .background(Color.brandLight)
                    }

                    List(filteredAndSortedCustomers) { customer in
                        CustomerListRow(customer: customer) {
                            selectedCustomer = customer
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .searchable(text: $searchText, prompt: "Search customers...")
                }
                .navigationTitle("Customers (\(filteredAndSortedCustomers.count))")
                .navigationBarItems(
                    trailing: Button(action: {
                        withAnimation {
                            showingFilters.toggle()
                        }
                    }) {
                        Image(systemName: showingFilters ? "line.horizontal.3.decrease.circle.fill" : "line.horizontal.3.decrease.circle")
                            .foregroundColor(.brandPrimary)
                    }
                )
                .sheet(item: $selectedCustomer) { customer in
                    CustomerDetailView(customer: customer)
                }
            }
        }
    }
}

struct FilterControlsView: View {
    @Binding var selectedSort: CustomerSortOption
    @Binding var showRecentVisitsOnly: Bool

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Sort by:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Picker("Sort", selection: $selectedSort) {
                    ForEach(CustomerSortOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }

            Toggle("Recent visits only", isOn: $showRecentVisitsOnly)
                .font(.subheadline)
        }
    }
}

struct CustomerListRow: View {
    let customer: Customer
    let onTap: () -> Void
    @EnvironmentObject var dataService: DataService
    @EnvironmentObject var locationManager: LocationManager

    var lastVisit: Visit? {
        dataService.getLastVisitForCustomer(customer.id)
    }

    var distanceText: String? {
        guard let currentLocation = locationManager.location else { return nil }
        let distance = currentLocation.distance(from: customer.location)
        let miles = distance * 0.000621371 // Convert meters to miles
        return String(format: "%.1f mi", miles)
    }

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(customer.company)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("Contact: \(customer.name)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    HStack {
                        if let lastVisit = lastVisit {
                            Text("Last visit: \(lastVisit.checkInTime, style: .date)")
                                .font(.caption)
                                .foregroundColor(.brandPrimary)
                        } else if let lastContact = customer.lastContact {
                            Text("Last contact: \(lastContact, style: .date)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if let distance = distanceText {
                            Text(distance)
                                .font(.caption)
                                .foregroundColor(.brandSecondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.brandSecondary.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }

                Image(systemName: "chevron.right")
                    .foregroundColor(.brandPrimary)
                    .font(.caption)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CustomerListView()
        .environmentObject(DataService())
}

