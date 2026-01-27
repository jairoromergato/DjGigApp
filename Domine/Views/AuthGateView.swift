import SwiftUI
struct AuthGateView: View {

    @StateObject private var session: UserSession

    init() {
        let authRepository = FakeAuthRepository()
        let authUseCase = DefaultAuthUseCase(repository: authRepository)
        _session = StateObject(
            wrappedValue: UserSession(authUseCase: authUseCase)
        )
    }

    var body: some View {
        Group {
            if session.isLoggedIn {
                HomeView()
            } else {
                LoginView(session: session)
            }
        }
        .task {
            await session.loadSession()
        }
    }
}

final class FakeAuthRepository: AuthRepository {

    private var users: [String: String] = [:]
    private var current: User?

    func currentUser() async -> User? {
        current
    }

    func login(email: String, password: String) async throws -> User {
        guard let storedPassword = users[email] else {
            throw AuthError.emailNotRegistered
        }

        guard storedPassword == password else {
            throw AuthError.invalidCredentials
        }

        let user = User(id: email, email: email)
        current = user
        return user
    }

    func register(email: String, password: String) async throws -> User {
        users[email] = password
        let user = User(id: email, email: email)
        current = user
        return user
    }

    func logout() async throws {
        current = nil
    }
}


