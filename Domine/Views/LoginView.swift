import SwiftUI

struct LoginView: View {
    @ObservedObject var session: UserSession
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            AppTheme.bg.ignoresSafeArea()
            VStack(spacing: 24) {
                Spacer()
                HStack {
                icon: do {
                    Image(systemName: "headphones")
                }
                    Text("DJ Gig App")
                        .font(.largeTitle.bold())
                }
                .foregroundStyle(AppTheme.accent)
                
                VStack(spacing: 16) {
                    TextField(
                        "Correo electrónico",
                        text: $email,
                        prompt: Text("Correo electrónico").foregroundStyle(AppTheme.textSecondary)
                    )
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .padding()
                    .foregroundStyle(.white)
                    .background(.secondary)
                    .cornerRadius(12)
                    
                    SecureField("Contraseña", text: $password, prompt: Text("Contraseña").foregroundStyle(AppTheme.textSecondary))
                        .padding()
                        .foregroundStyle(.white)
                        .background(.secondary)
                        .cornerRadius(12)
                    
                }
                
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
                
                Button {
                    login()
                } label: {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Iniciar sesión")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundStyle(AppTheme.accent)
                .cornerRadius(14)
                .disabled(isLoading)
                
                Button {
                    register()
                } label: {
                    Text("Crear cuenta")
                        .font(.footnote.bold())
                        .foregroundStyle(AppTheme.accent)
                    
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: 420)
        }
    }
    
    
    private func login() {
        Task {
            do {
                try await session.login(
                    email: email,
                    password: password
                )
            } catch {
                errorMessage = "Error al iniciar sesión"
            }
        }
    }

    private func register() {
        Task {
            do {
                try await session.register(
                    email: email,
                    password: password
                )
            } catch {
                errorMessage = "No se pudo registrar el email"
            }
        }
    }

}

//
//#Preview {
//    LoginView()
//}
