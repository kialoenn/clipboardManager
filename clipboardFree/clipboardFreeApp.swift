//
//  clipboardFreeApp.swift
//  clipboardFree
//
//  Created by Man Sun on 2024-08-28.
//

import SwiftUI

@main
struct clipboardFreeApp: App {
    @StateObject private var clipboardManager = ClipboardManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(clipboardManager)
        }
    }
}
