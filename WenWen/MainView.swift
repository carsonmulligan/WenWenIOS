import SwiftUI

struct MainView: View {
    @StateObject private var chatStore = ChatStore()
    @State private var showingSidebar = false
    
    var body: some View {
        NavigationView {
            Group {
                if let currentSession = chatStore.currentSession {
                    ChatView(session: currentSession)
                        .navigationBarItems(
                            leading: Button(action: { showingSidebar.toggle() }) {
                                Image(systemName: "sidebar.left")
                            },
                            trailing: Button(action: { chatStore.createNewSession() }) {
                                Image(systemName: "square.and.pencil")
                            }
                        )
                } else {
                    WelcomeView()
                        .navigationBarItems(
                            leading: Button(action: { showingSidebar.toggle() }) {
                                Image(systemName: "sidebar.left")
                            }
                        )
                }
            }
        }
        .sheet(isPresented: $showingSidebar) {
            SidebarView(sessions: chatStore.sessions) { sessionId in
                chatStore.loadSession(sessionId)
                showingSidebar = false
            }
        }
        .environmentObject(chatStore)
    }
} 