//
//  WenWenApp.swift
//  WenWen
//
//  Created by Carson Mulligan on 1/15/25.
//

import SwiftUI

@main
struct WenWenApp: App {
    @StateObject private var chatViewModel = ChatViewModel()
    
    var body: some Scene {
        WindowGroup {
            ChatView()
                .environmentObject(chatViewModel)
        }
    }
}
