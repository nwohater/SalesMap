//
//  AuthenticationService.swift
//  SalesMap
//
//  Created by Brandon Lackey on 9/11/25.
//

import Foundation
import Combine

class AuthenticationService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let userDefaults = UserDefaults.standard
    private let userKey = "current_user"
    
    init() {
        loadSavedUser()
    }
    
    // MARK: - Mock Authentication
    func signIn(email: String, password: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        await MainActor.run {
            // Mock authentication - accept any email/password for now
            if !email.isEmpty && !password.isEmpty {
                let user = User.mockUser
                self.currentUser = user
                self.isAuthenticated = true
                self.saveUser(user)
            } else {
                self.errorMessage = "Please enter both email and password"
            }
            self.isLoading = false
        }
    }
    
    func signOut() {
        currentUser = nil
        isAuthenticated = false
        userDefaults.removeObject(forKey: userKey)
    }
    
    // MARK: - Persistence
    private func saveUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            userDefaults.set(encoded, forKey: userKey)
        }
    }
    
    private func loadSavedUser() {
        if let data = userDefaults.data(forKey: userKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
            isAuthenticated = true
        }
    }
    
    // MARK: - Future Azure AD Integration
    // This is where we'll integrate Microsoft Authentication Library (MSAL) in Phase 2
    func signInWithAzureAD() async {
        // TODO: Implement Azure AD authentication
        // This will replace the mock authentication in Phase 2
    }
}
