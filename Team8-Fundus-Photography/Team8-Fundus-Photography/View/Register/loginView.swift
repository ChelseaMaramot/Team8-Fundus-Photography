import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil
    @State private var emailError: String? = nil
    @State private var passwordError: String? = nil
    @State private var isLoading: Bool = false
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack(spacing: geometry.size.height * 0.03) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome")
                            .font(.system(size: geometry.size.width * 0.08, weight: .bold))
                            .foregroundColor(.blue)
                        
                        Text("Log in to continue and explore amazing features tailored just for you.")
                            .font(.system(size: geometry.size.width * 0.04))
                            .lineLimit(nil) 
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.bottom, geometry.size.height * 0.05)
                    .frame(width: geometry.size.width * 0.85)
                    
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .fontWeight(.medium)
                            .font(.system(size: geometry.size.width * 0.05))
                            .padding(.horizontal)
                        TextField("\("example@example.com")", text: $email)
                            .frame(height: 44)
                            .padding(.horizontal)
                            .background(emailError == nil ? Color.white : Color.red.opacity(0.1))
                            .cornerRadius(8)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                        if let error = emailError {
                            Text(error)
                                .font(.system(size: geometry.size.width * 0.04))
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                    }
                    .frame(width: geometry.size.width * 0.85)
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .fontWeight(.medium)
                            .font(.system(size: geometry.size.width * 0.05))
                            .padding(.horizontal)
                        SecureField("password", text: $password)
                            .frame(height: 44)
                            .padding(.horizontal)
                            .background(passwordError == nil ? Color.white : Color.red.opacity(0.1))
                            .cornerRadius(8)
                            .disableAutocorrection(true)
                        if let error = passwordError {
                            Text(error)
                                .font(.system(size: geometry.size.width * 0.04))
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                    }
                    .frame(width: geometry.size.width * 0.85)
                    .padding(.bottom, geometry.size.height * 0.05)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.system(size: geometry.size.width * 0.04))
                            .foregroundColor(.red)
                            .padding(.bottom, geometry.size.height * 0.03)
                            .padding(.horizontal)
                    }
                    

                    Button(action: {
                        emailError = nil
                        passwordError = nil
                        errorMessage = nil
                        
                        guard !email.isEmpty, !password.isEmpty else {
                            if email.isEmpty {
                                emailError = "Email cannot be empty."
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
                        authService.regularSignIn(email: email, password: password) { error in
                            isLoading = false
                            if let e = error {
                                
                                if e.localizedDescription.contains("malformed") || e.localizedDescription.contains("expired") {
                                    errorMessage = "The email or password you entered is incorrect. Please check and try again."
                                } else {
                                    errorMessage = e.localizedDescription
                                }
                                
                            } else {
                                errorMessage = nil
                                dismiss()
                            }
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(width: geometry.size.width * 0.8, height: 60)
                        } else {
                            Text("Login")
                                .font(.system(size: geometry.size.width * 0.06))
                                .fontWeight(.medium)
                                .padding()
                                .frame(width: geometry.size.width * 0.8, height: 60)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(30)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.gray)
                            .font(.system(size: geometry.size.width * 0.04))
                        
                        NavigationLink(destination: signUpView()) {
                            Text("Sign Up")
                                .foregroundColor(.blue)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.top, geometry.size.height * 0.05)
                }
                .textFieldStyle(.roundedBorder)
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
}

#Preview {
    LoginView()
}
