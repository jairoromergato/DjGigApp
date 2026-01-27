import SwiftUI

struct LoginView: View {
    @ObservedObject var session: UserSession
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showRegister = false
    @State private var isPasswordVisible = false
    
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
                    HStack {
                        Group {
                            if isPasswordVisible {
                                TextField(
                                    "Contraseña",
                                    text: $password,
                                    prompt: Text("Contraseña").foregroundStyle(AppTheme.textSecondary)
                                )
                            } else {
                                SecureField(
                                    "Contraseña",
                                    text: $password,
                                    prompt: Text("Contraseña").foregroundStyle(AppTheme.textSecondary)
                                )
                            }
                        }
                        .textInputAutocapitalization(.never)
                        .foregroundStyle(.white)

                        Button {
                            isPasswordVisible.toggle()
                        } label: {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    .padding()
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
        .sheet(isPresented: $showRegister) {
            RegisterView(session: session)
        }
    }
    
    
    private func login() {
        guard !email.isEmpty else {
            errorMessage = "Introduce un email"
            return
        }

        guard !password.isEmpty else {
            errorMessage = "Introduce una contraseña"
            return
        }

        Task {
            do {
                try await session.login(email: email, password: password)
            } catch AuthError.emailNotRegistered {
                errorMessage = "Email no registrado"
                showRegister = true
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


#Preview {
    LoginView(session: UserSession(authUseCase: PreviewAuthUseCase()))
}

