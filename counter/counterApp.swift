//
//  counterApp.swift
//  counter
//
//  Created by Ashutosh Kumar Kushwaha on 29/08/25.
//

import SwiftUI

@main
struct counterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    handleWidgetURL(url)
                }
        }
    }
    
    private func handleWidgetURL(_ url: URL) {
        guard let scheme = url.scheme, scheme == "expensetracker" else { return }
        
        let host = url.host()
        switch host {
        case "add-expense":
            // Open app to add expense screen
            NotificationCenter.default.post(name: NSNotification.Name("OpenAddExpense"), object: nil)
        case "open":
            // Just open the app (default behavior)
            break
        default:
            break
        }
    }
}
