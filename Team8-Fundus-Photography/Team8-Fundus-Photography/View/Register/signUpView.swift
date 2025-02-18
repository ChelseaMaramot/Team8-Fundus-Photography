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
    
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View {
        NavigationView {
            VStack(){
                
                VStack(alignment: .leading, spacing: 8){
                    Text("New Account")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.blue)
                }.padding(.bottom, 50)
            
         
                VStack(alignment: .leading, spacing: 8){
                    Text("Fist Name")
                        .fontWeight(.medium)
                        .font(.system(size: 20))
                        .frame(alignment: .leading)
                    TextField(
                        "Jane",
                        text: $firstName
                    )
                        .frame(height: 44)
                        .background(Color.white)
                        .cornerRadius(4)
                        .disableAutocorrection(true)
                    
                    
                    Text("Last Name")
                        .fontWeight(.medium)
                        .font(.system(size: 20))
                        .frame(alignment: .leading)
                    TextField(
                        "Doe",
                        text: $lastName
                    )
                        .frame(height: 44)
                        .background(Color.white)
                        .cornerRadius(4)
                        .disableAutocorrection(true)
                    
                }
                .padding(.horizontal, 30)
                
                
                VStack(alignment: .leading, spacing: 8){
                    Text("Email")
                        .fontWeight(.medium)
                        .font(.system(size: 20))
                        .frame(alignment: .leading)
                    TextField(
                        "example@example.com",
                        text: $email
                    )
                    .frame(height: 44)
                    .background(Color.white)
                    .cornerRadius(4)
                    .disableAutocorrection(true)
                }
                .padding(.horizontal, 30)
                
                
                VStack(alignment: .leading, spacing: 8){
                    Text("Password")
                        .fontWeight(.medium)
                        .font(.system(size: 20))
                        .frame(alignment: .leading)
                    SecureField(
                        "password",
                        text: $password
                    )
                    .frame(height: 44)
                    .background(Color.white)
                    .cornerRadius(4)
                    .disableAutocorrection(true)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
                
                
                Button("Sign Up"){
                    authService.regularCreateAccount(email: email, password: password, firstName: firstName, lastName: lastName){ error in
                        if let e = error {
                            print(e.localizedDescription)
                        }
                    }
                }
                    .font(.system(size: 24))
                    .fontWeight(.medium)
                    .padding()
                    .frame(width: 300, height: 60)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(30)
                
                HStack{
                    Text("Already have an account?")
                        .foregroundColor(.gray)
                    
                    NavigationLink(destination: loginView()){
                        Text("Login")
                    } .foregroundColor(.blue)
                        .fontWeight(.semibold)
                    
                   
                }
                .padding(.top, 80)
                
                
            }
            .textFieldStyle(.roundedBorder)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    signUpView().environmentObject(AuthService())
}
