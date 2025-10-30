//
//  DJGigsAppApp.swift
//  DJGigsApp
//
//  Created by Jairo Romero gato on 30/10/25.
//

import SwiftUI

@main
struct DJGigsAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
