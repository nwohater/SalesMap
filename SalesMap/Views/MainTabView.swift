//
//  MainTabView.swift
//  SalesMap
//
//  Created by Brandon Lackey on 9/11/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var authService = AuthenticationService()
    @StateObject private var dataService = DataService()
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                TabView {
                    MapView()
                        .tabItem {
                            Image(systemName: "map")
                            Text("Map")
                        }
                    
                    CustomerListView()
                        .tabItem {
                            Image(systemName: "person.3")
                            Text("Customers")
                        }
                    
                    VisitHistoryView()
                        .tabItem {
                            Image(systemName: "clock")
                            Text("Visits")
                        }
                    
                    ProfileView()
                        .tabItem {
                            Image(systemName: "person.circle")
                            Text("Profile")
                        }
                }
                .environmentObject(authService)
                .environmentObject(dataService)
                .environmentObject(locationManager)
                .onAppear {
                    locationManager.requestLocationPermission()
                    Task {
                        await dataService.fetchCustomers()
                        await dataService.fetchVisits()
                        await dataService.fetchDeliveries()
                    }
                }
            } else {
                LoginView()
                    .environmentObject(authService)
            }
        }
    }
}

#Preview {
    MainTabView()
}
