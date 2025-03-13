//
//  signUpView.swift
//  Team8-Fundus-Photography
//
//  Created by chelsea maramot on 2025-02-12.
//
import SwiftUI

struct signUpView: View {
    
    @State private var email: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var password: String = ""
    
    @State private var emailError: String? = nil
    @State private var firstNameError: String? = nil
    @State private var lastNameError: String? = nil
    @State private var passwordError: String? = nil
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false
    
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack(spacing: geometry.size.height * 0.02) {
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("New Account")
                            .font(.system(size: geometry.size.width * 0.08, weight: .bold))
                            .foregroundColor(.blue)
                        
                        Text("Create a new account to access advanced fundus photography tools and take the first step towards better eye health and diagnosis.")
                            .font(.system(size: geometry.size.width * 0.04))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.bottom, geometry.size.height * 0.03)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("First Name")
                                .fontWeight(.medium)
                                .font(.system(size: geometry.size.width * 0.05))
                            TextField("Jane", text: $firstName)
                                .frame(height: 44)
                                .background(firstNameError == nil ? Color.white : Color.red.opacity(0.1))
                                .cornerRadius(4)
                                .disableAutocorrection(true)
                                .padding(.trailing, 10)
                            if let error = firstNameError {
                                Text(error)
                                    .font(.system(size: geometry.size.width * 0.04))
                                    .foregroundColor(.red)
                                    .padding(.horizontal)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Last Name")
                                .fontWeight(.medium)
                                .font(.system(size: geometry.size.width * 0.05))
                            TextField("Doe", text: $lastName)
                                .frame(height: 44)
                                .background(lastNameError == nil ? Color.white : Color.red.opacity(0.1))
                                .cornerRadius(4)
                                .disableAutocorrection(true)
                            if let error = lastNameError {
                                Text(error)
                                    .font(.system(size: geometry.size.width * 0.04))
                                    .foregroundColor(.red)
                                    .padding(.horizontal)
                            }
                        }
                    }
            
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .fontWeight(.medium)
                            .font(.system(size: geometry.size.width * 0.05))
                        TextField("\("example@example.com")", text: $email)
                            .frame(height: 44)
                            .background(emailError == nil ? Color.white : Color.red.opacity(0.1))
                            .cornerRadius(4)
                            .disableAutocorrection(true)
                        if let error = emailError {
                            Text(error)
                                .font(.system(size: geometry.size.width * 0.04))
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                    }


                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .fontWeight(.medium)
                            .font(.system(size: geometry.size.width * 0.05))
                        SecureField("password", text: $password)
                            .frame(height: 44)
                            .background(passwordError == nil ? Color.white : Color.red.opacity(0.1))
                            .cornerRadius(4)
                            .disableAutocorrection(true)
                        if let error = passwordError {
                            Text(error)
                                .font(.system(size: geometry.size.width * 0.04))
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, geometry.size.height * 0.03)

                    // General Error Message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.system(size: geometry.size.width * 0.04))
                            .foregroundColor(.red)
                            .padding(.bottom, geometry.size.height * 0.02)
                    }

                    Button(action: {

                        emailError = nil
                        firstNameError = nil
                        lastNameError = nil
                        passwordError = nil
                        errorMessage = nil
                        
                        // Basic validation
                        guard !email.isEmpty, !firstName.isEmpty, !lastName.isEmpty, !password.isEmpty else {
                            if email.isEmpty {
                                emailError = "Email cannot be empty."
                            }
                            if firstName.isEmpty {
                                firstNameError = "First Name cannot be empty."
                            }
                            if lastName.isEmpty {
                                lastNameError = "Last Name cannot be empty."
                            }
                            if password.isEmpty {
                                passwordError = "Password cannot be empty."
                            }
                            return
                        }
                        
                        guard isValidEmail(email) else {
                            emailError = "Please enter a valid email address."
                            return
                        }

                        isLoading = true
                        authService.regularCreateAccount(email: email, password: password, firstName: firstName, lastName: lastName) { error in
                            isLoading = false
                            if let e = error {
                                errorMessage = e.localizedDescription
                            } else {
                                dismiss()
                            }
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(width: geometry.size.width * 0.75, height: 60)
                        } else {
                            Text("Sign Up")
                                .font(.system(size: geometry.size.width * 0.06))
                                .fontWeight(.medium)
                                .padding()
                                .frame(width: geometry.size.width * 0.75, height: 60)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(30)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.gray)
                            .font(.system(size: geometry.size.width * 0.04))
                        NavigationLink(destination: LoginView()) {
                            Text("Login")
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.top, geometry.size.height * 0.05)
                    
                }
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, geometry.size.width * 0.1)
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    // Email validation function
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
}

#Preview {
    signUpView().environmentObject(AuthService())
}
