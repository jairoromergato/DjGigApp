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

    private var storedUser: User?

    func currentUser() async -> User? {
        storedUser
    }

    func login(email: String, password: String) async throws -> User {
        let user = User(id: UUID().uuidString, email: email)
        storedUser = user
        return user
    }

    func register(email: String, password: String) async throws -> User {
        let user = User(id: UUID().uuidString, email: email)
        storedUser = user
        return user
    }

    func logout() async throws {
        storedUser = nil
    }
}

