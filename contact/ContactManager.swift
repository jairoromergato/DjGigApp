import Foundation
import Contacts
import ContactsUI
import SwiftUI

class ContactManager: NSObject, ObservableObject {
    private let store = CNContactStore()
    @Published var selectedContact: CNContact?

    func requestAccess(_ completion: @escaping (Bool) -> Void) {
        store.requestAccess(for: .contacts) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
}

struct ContactPickerView: UIViewControllerRepresentable {
    @ObservedObject var manager: ContactManager

    func makeCoordinator() -> Coordinator {
        Coordinator(manager: manager)
    }

    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}

    class Coordinator: NSObject, CNContactPickerDelegate {
        var manager: ContactManager

        init(manager: ContactManager) {
            self.manager = manager
        }

        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            manager.selectedContact = contact
        }
    }
}
