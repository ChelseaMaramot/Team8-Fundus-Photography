import SwiftUI


struct loginView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(){
                
                VStack(alignment: .leading, spacing: 8){
                    Text("Welcome")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.blue)
                    Text("Sign in to continue and explore amazing features tailored just for you.")
                }.padding(.bottom, 50)
            
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
                
                
                Button("Login"){
                    
                    authService.regularSignIn(email: email, password: password) { error in
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
                    Text("Don't have an account?")
                        .foregroundColor(.gray)
                    
                    NavigationLink(destination: signUpView()){
                        Text("Sign Up")
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
    loginView()
}
