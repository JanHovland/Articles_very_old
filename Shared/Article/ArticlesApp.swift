//
//  ArticlesApp.swift
//  Shared
//
//  Created by Jan Hovland on 04/01/2021.
//

import SwiftUI

@main
struct ArticlesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            Articles()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
