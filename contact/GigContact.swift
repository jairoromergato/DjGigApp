import Foundation
import SwiftData

@Model
final class GigContact {
    @Attribute(.unique) var id: String
    var name: String
    var phone: String?
    var email: String?

    init(id: String, name: String, phone: String? = nil, email: String? = nil) {
        self.id = id
        self.name = name
        self.phone = phone
        self.email = email
    }
}
