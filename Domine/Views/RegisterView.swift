import SwiftUI
struct RegisterView: View {
    
    @ObservedObject var session: UserSession
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isPasswordVisible = false
    
    var body: some View {
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

            Button("Crear cuenta") {
                register()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.secondary)
            .foregroundColor(.white)
            .cornerRadius(14)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.bg)
        .ignoresSafeArea()
    }
    
    private func register() {
        guard !password.isEmpty else {
            errorMessage = "Introduce una contraseña"
            return
        }
        
        Task {
            do {
                try await session.register(email: email, password: password)
            } catch {
                errorMessage = "No se pudo registrar"
            }
        }
    }
}

#Preview {
    RegisterView(session: UserSession(authUseCase: PreviewAuthUseCase()))
}
