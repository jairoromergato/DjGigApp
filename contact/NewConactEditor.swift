//import SwiftUI
//import ContactsUI
//
//struct NewContactEditor: UIViewControllerRepresentable {
//    func makeUIViewController(context: Context) -> UIViewController {
//        let controller = CNContactViewController(forNewContact: nil)
//        controller.contactStore = CNContactStore()
//
//        let nav = UINavigationController(rootViewController: controller)
//        return nav
//    }
//
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
//}
//

import SwiftUI
import ContactsUI

struct NewContactEditor: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        let newContact = CNMutableContact()
        let controller = CNContactViewController(forNewContact: newContact)

        controller.delegate = context.coordinator
        controller.contactStore = CNContactStore()

        let nav = UINavigationController(rootViewController: controller)
        return nav
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}

    class Coordinator: NSObject, CNContactViewControllerDelegate {
        let parent: NewContactEditor

        init(_ parent: NewContactEditor) {
            self.parent = parent
        }

        func contactViewController(_ viewController: CNContactViewController,
                                   didCompleteWith contact: CNContact?) {
            parent.dismiss()
        }
    }
}
