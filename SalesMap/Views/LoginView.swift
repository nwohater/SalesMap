//
//  LoginView.swift
//  SalesMap
//
//  Created by Brandon Lackey on 9/11/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Logo and Title
                VStack(spacing: 20) {
                    Image("SalesMapLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                    
                    Text("SalesMap")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Mobile CRM with Mapping")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Login Form
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.headline)
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.headline)
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    if let errorMessage = authService.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.brandRed)
                            .font(.caption)
                    }
                    
                    Button(action: {
                        Task {
                            await authService.signIn(email: email, password: password)
                        }
                    }) {
                        HStack {
                            if authService.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text("Sign In")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brandPrimary)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(authService.isLoading || email.isEmpty || password.isEmpty)
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Mock credentials hint
                VStack(spacing: 8) {
                    Text("For MVP Testing:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Use any email and password to sign in")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationService())
}
