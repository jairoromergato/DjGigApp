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
        NavigationStack {
            ZStack {
                AppTheme.bg.ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    HStack(spacing: 8) {
                        Image(systemName: "headphones")
                        Text("DJ Gig App")
                            .font(.largeTitle.bold())
                    }
                    .foregroundStyle(AppTheme.accent)

                    VStack(spacing: 16) {
                        TextField(
                            "Correo electrónico",
                            text: $email,
                            prompt: Text("Correo electrónico")
                                .foregroundStyle(AppTheme.textSecondary)
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
                                        prompt: Text("Contraseña")
                                            .foregroundStyle(AppTheme.textSecondary)
                                    )
                                } else {
                                    SecureField(
                                        "Contraseña",
                                        text: $password,
                                        prompt: Text("Contraseña")
                                            .foregroundStyle(AppTheme.textSecondary)
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
                            ProgressView().tint(.white)
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
                        errorMessage = nil
                        showRegister = true
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
            .navigationDestination(isPresented: $showRegister) {
                RegisterView(session: session)
            }
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

        isLoading = true
        errorMessage = nil

        Task {
            defer { isLoading = false }

            do {
                try await session.login(email: email, password: password)
            } catch AuthError.emailNotRegistered {
                errorMessage = "Email no registrado"
            } catch {
                errorMessage = "Error al iniciar sesión"
            }
        }
    }
}
