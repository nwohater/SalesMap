//
//  MapView.swift
//  SalesMap
//
//  Created by Brandon Lackey on 9/11/25.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var dataService: DataService
    @EnvironmentObject var locationManager: LocationManager
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3348, longitude: -122.0090), // Cupertino, CA (Apple Park)
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var radiusInMiles: Double = 25.0
    @State private var selectedCustomer: Customer?
    @State private var showingMapFilters = false
    @State private var selectedTierFilter: CustomerFilterOption = .all
    @State private var showUnvisitedOnly = false

    var filteredCustomers: [Customer] {
        let allCustomers = dataService.customers

        // If we have location, filter by radius, otherwise show all customers
        let customersToFilter: [Customer]
        if let currentLocation = locationManager.location {
            customersToFilter = dataService.getCustomersWithinRadius(from: currentLocation, radiusInMiles: radiusInMiles)
        } else {
            customersToFilter = allCustomers
        }

        return applyFilters(customersToFilter)
    }

    private func applyFilters(_ customers: [Customer]) -> [Customer] {
        var filtered = customers

        // Apply tier filter
        if selectedTierFilter != .all {
            filtered = filtered.filter { customer in
                customer.tier.lowercased() == selectedTierFilter.rawValue.lowercased()
            }
        }

        // Apply unvisited filter
        if showUnvisitedOnly {
            let visitedCustomerIds = Set(dataService.visits.map { $0.customerId })
            filtered = filtered.filter { !visitedCustomerIds.contains($0.id) }
        }

        return filtered
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: filteredCustomers) { customer in
                    MapAnnotation(coordinate: customer.coordinate) {
                        CustomerMapPin(customer: customer) {
                            selectedCustomer = customer
                        }
                    }
                }
                .onAppear {
                    locationManager.requestLocationPermission()
                    updateRegionToUserLocation()
                }
                .onChange(of: locationManager.location) { _ in
                    updateRegionToUserLocation()
                }
                
                // Controls
                VStack {
                    // Top controls
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation {
                                showingMapFilters.toggle()
                            }
                        }) {
                            Image(systemName: showingMapFilters ? "line.horizontal.3.decrease.circle.fill" : "line.horizontal.3.decrease.circle")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .background(Color(.systemBackground))
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        }
                        .padding(.trailing, 16)
                        .padding(.top, 16)
                    }

                    // Filter controls
                    if showingMapFilters {
                        MapFilterControlsView(
                            selectedTierFilter: $selectedTierFilter,
                            showUnvisitedOnly: $showUnvisitedOnly,
                            customerCount: filteredCustomers.count
                        )
                        .padding(.horizontal, 16)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    Spacer()

                    // Bottom controls
                    HStack {
                        Spacer()
                        RadiusControlView(radiusInMiles: $radiusInMiles)
                            .padding(.trailing, 16)
                            .padding(.bottom, 100) // Above tab bar
                    }
                }
                
                // Loading indicator
                if dataService.isLoading {
                    VStack {
                        ProgressView("Loading customers...")
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
            }
            .navigationTitle("Map (\(filteredCustomers.count) customers)")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedCustomer) { customer in
                CustomerDetailView(customer: customer)
            }
        }
    }
    
    private func updateRegionToUserLocation() {
        guard let userLocation = locationManager.location else { return }
        
        withAnimation {
            region = MKCoordinateRegion(
                center: userLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }
}

struct CustomerMapPin: View {
    let customer: Customer
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title)
                    .foregroundColor(colorForTier(customer.tier))
                    .background(Color.white)
                    .clipShape(Circle())
                
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.caption)
                    .foregroundColor(colorForTier(customer.tier))
                    .offset(x: 0, y: -5)
            }
        }
    }
    
    private func colorForTier(_ tier: String) -> Color {
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

struct RadiusControlView: View {
    @Binding var radiusInMiles: Double
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(Int(radiusInMiles)) miles")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Slider(value: $radiusInMiles, in: 5...50, step: 5)
                .frame(width: 120)
                .accentColor(.blue)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

struct MapFilterControlsView: View {
    @Binding var selectedTierFilter: CustomerFilterOption
    @Binding var showUnvisitedOnly: Bool
    let customerCount: Int

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("\(customerCount) customers")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }

            VStack(spacing: 8) {
                HStack {
                    Text("Tier:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Picker("Tier Filter", selection: $selectedTierFilter) {
                        ForEach(CustomerFilterOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Toggle("Unvisited only", isOn: $showUnvisitedOnly)
                    .font(.subheadline)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

#Preview {
    MapView()
        .environmentObject(DataService())
        .environmentObject(LocationManager())
}
