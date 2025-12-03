import SwiftUI
import ContactsUI

struct NewContactEditor: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = CNContactViewController(forNewContact: nil)
        controller.contactStore = CNContactStore()

        let nav = UINavigationController(rootViewController: controller)
        return nav
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
