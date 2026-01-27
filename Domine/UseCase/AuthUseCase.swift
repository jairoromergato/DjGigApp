protocol AuthUseCase {
    func currentUser () async -> User?
    func login (email: String, password: String) async throws -> User
    func register (email: String, password: String) async throws -> User
    func logout () async throws
}

final class DefaultAuthUseCase: AuthUseCase {
    
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func currentUser() async -> User? {
        await repository.currentUser()
    }

    func login(email: String, password: String) async throws -> User {
        try await repository.login(email: email, password: password)
    }

    func register(email: String, password: String) async throws -> User {
        try await repository.register(email: email, password: password)
    }

    func logout() async throws {
        try await repository.logout()
    }
}

final class PreviewAuthUseCase: AuthUseCase {
    func currentUser() async -> User? {
        nil
    }
    
    func login(email: String, password: String) async throws -> User {
        User(id: "id", email: "email")
    }
    
    func register(email: String, password: String) async throws -> User {
        User(id: "id", email: "email")
    }
    
    func logout() async throws {
    }
    
    
}
