import SwiftUI
@MainActor

final class UserSession: ObservableObject {
    
    @Published private(set) var authState: AuthState = .loading
    @Published private(set) var user: User?
    private let authUseCase: AuthUseCase

    init(authUseCase: AuthUseCase) {
        self.authUseCase = authUseCase
    }

    func loadSession() async {
        user = await authUseCase.currentUser()
        authState = user == nil ? .loggedOut : .loggedIn
    }

    func login(email: String, password: String) async throws {
        user = try await authUseCase.login(email: email, password: password)
        authState = .loggedIn
    }

    func register(email: String, password: String) async throws {
        user = try await authUseCase.register(email: email, password: password)
        authState = .loggedIn
    }

    func logout() async throws {
        try await authUseCase.logout()
        user = nil
        authState = .loggedOut
    }

    var isLoggedIn: Bool {
        user != nil
    }
}

enum AuthState {
    case loading
    case loggedOut
    case loggedIn
}

