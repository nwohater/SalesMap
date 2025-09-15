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
    @State private var mapPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.3348, longitude: -122.0090),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    @State private var radiusInMiles: Double = 25.0
    @State private var selectedCustomer: Customer?
    @State private var showingMapFilters = false

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

        // Apply unvisited filter
        if showUnvisitedOnly {
            let visitedCustomerIds = Set(dataService.visits.map { $0.customerId })
            filtered = filtered.filter { !visitedCustomerIds.contains($0.id) }
        }

        return filtered
    }

    private func centerOnCustomers() {
        let customers = filteredCustomers
        guard !customers.isEmpty else { return }

        if customers.count == 1 {
            // If only one customer, center on them with a reasonable zoom
            let customer = customers[0]
            let newRegion = MKCoordinateRegion(
                center: customer.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            withAnimation(.easeInOut(duration: 1.0)) {
                region = newRegion
                mapPosition = .region(newRegion)
            }
        } else {
            // Calculate bounding box for all customers
            let latitudes = customers.map { $0.latitude }
            let longitudes = customers.map { $0.longitude }

            let minLat = latitudes.min() ?? 0
            let maxLat = latitudes.max() ?? 0
            let minLon = longitudes.min() ?? 0
            let maxLon = longitudes.max() ?? 0

            let centerLat = (minLat + maxLat) / 2
            let centerLon = (minLon + maxLon) / 2

            let latDelta = max(maxLat - minLat, 0.01) * 1.3 // Add 30% padding
            let lonDelta = max(maxLon - minLon, 0.01) * 1.3 // Add 30% padding

            let newRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
                span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
            )
            withAnimation(.easeInOut(duration: 1.0)) {
                region = newRegion
                mapPosition = .region(newRegion)
            }
        }
    }

    private func centerOnMyLocation() {
        guard let currentLocation = locationManager.location else { return }

        let newRegion = MKCoordinateRegion(
            center: currentLocation.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        withAnimation(.easeInOut(duration: 1.0)) {
            region = newRegion
            mapPosition = .region(newRegion)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Map(position: $mapPosition, interactionModes: .all) {
                    UserAnnotation()

                    ForEach(filteredCustomers) { customer in
                        Annotation(customer.name, coordinate: customer.coordinate) {
                            CustomerMapPin(customer: customer) {
                                selectedCustomer = customer
                            }
                        }
                    }
                }
                .mapControlVisibility(.hidden)
                .onAppear {
                    locationManager.requestLocationPermission()
                    updateRegionToUserLocation()
                }
                .onChange(of: locationManager.location) {
                    updateRegionToUserLocation()
                }
                
                // Controls
                VStack {
                    // Top controls
                    HStack {
                        Spacer()

                        // Center on my location button
                        Button(action: {
                            centerOnMyLocation()
                        }) {
                            Image(systemName: "scope")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .background(Color(.systemBackground))
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        }
                        .padding(.trailing, 8)
                        .padding(.top, 16)
                        .disabled(locationManager.location == nil)
                        .opacity(locationManager.location == nil ? 0.5 : 1.0)

                        // Center on customers button
                        Button(action: {
                            centerOnCustomers()
                        }) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .background(Color(.systemBackground))
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        }
                        .padding(.trailing, 8)
                        .padding(.top, 16)
                        .disabled(filteredCustomers.isEmpty)
                        .opacity(filteredCustomers.isEmpty ? 0.5 : 1.0)

                        // Filter button
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

        let newRegion = MKCoordinateRegion(
            center: userLocation.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        withAnimation {
            region = newRegion
            mapPosition = .region(newRegion)
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
                    .foregroundColor(.blue)
                    .background(Color.white)
                    .clipShape(Circle())

                Image(systemName: "arrowtriangle.down.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .offset(x: 0, y: -5)
            }
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

            Toggle("Unvisited only", isOn: $showUnvisitedOnly)
                .font(.subheadline)
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
