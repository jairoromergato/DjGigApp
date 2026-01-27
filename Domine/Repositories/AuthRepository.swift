protocol AuthRepository {
    func currentUser () async -> User?
    func login (email: String, password: String) async throws -> User
    func register (email: String, password: String) async throws -> User
    func logout () async throws
}
