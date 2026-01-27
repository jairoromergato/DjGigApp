import SwiftUI
@MainActor

final class UserSession: ObservableObject {

    @Published private(set) var user: User?
    private let authUseCase: AuthUseCase

    init(authUseCase: AuthUseCase) {
        self.authUseCase = authUseCase
    }

    func loadSession() async {
        user = await authUseCase.currentUser()
    }

    func login(email: String, password: String) async throws {
        user = try await authUseCase.login(email: email, password: password)
    }

    func register(email: String, password: String) async throws {
        user = try await authUseCase.register(email: email, password: password)
    }

    func logout() async throws {
        try await authUseCase.logout()
        user = nil
    }

    var isLoggedIn: Bool {
        user != nil
    }
}

