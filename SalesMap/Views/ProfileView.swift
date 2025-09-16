//
//  ProfileView.swift
//  SalesMap
//
//  Created by Brandon Lackey on 9/11/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var dataService: DataService
    @State private var showingSignOutConfirm = false
    
    var totalVisits: Int {
        dataService.visits.count
    }
    
    var totalCustomers: Int {
        dataService.customers.count
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
                
                List {
                    // User Information
                    Section("Profile") {
                        if let user = authService.currentUser {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.blue)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(user.name)
                                        .font(.headline)
                                    Text(user.email)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text(user.role.displayName)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(4)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    
                    // Statistics
                    Section("Statistics") {
                        HStack {
                            Image(systemName: "person.3")
                                .foregroundColor(.brandPrimary)
                            Text("Total Customers")
                            Spacer()
                            Text("\(totalCustomers)")
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.brandSuccess)
                            Text("Total Visits")
                            Spacer()
                            Text("\(totalVisits)")
                                .fontWeight(.semibold)
                        }
                        
                        if let user = authService.currentUser {
                            HStack {
                                Image(systemName: "map")
                                    .foregroundColor(.brandSecondary)
                                Text("Territory")
                                Spacer()
                                Text(user.territoryId)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    
                    // Settings
                    Section("Settings") {
                        HStack {
                            Image(systemName: "location")
                                .foregroundColor(.brandPrimary)
                            Text("Location Services")
                            Spacer()
                            Text("Enabled")
                                .foregroundColor(.brandSuccess)
                        }
                        
                        HStack {
                            Image(systemName: "bell")
                                .foregroundColor(.brandSecondary)
                            Text("Notifications")
                            Spacer()
                            Text("Enabled")
                                .foregroundColor(.brandSuccess)
                        }
                    }
                    
                    // Actions
                    Section {
                        Button(action: {
                            showingSignOutConfirm = true
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Sign Out")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.brandRed)
                    }
                }
                .navigationTitle("Profile")
                .alert("Sign Out?", isPresented: $showingSignOutConfirm) {
                    Button("Cancel", role: .cancel) {}
                    Button("Sign Out", role: .destructive) {
                        authService.signOut()
                    }
                } message: {
                    Text("You will be signed out of SalesMap.")
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationService())
        .environmentObject(DataService())
}
