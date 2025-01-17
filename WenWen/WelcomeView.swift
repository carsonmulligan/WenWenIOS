import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var chatStore: ChatStore
    @StateObject private var viewModel = ChatViewModel()
    
    let conversationStarters = [
        "教我三十六计的一个计谋，用ASCII艺术来解释",
        "给我念一首王梵志的古诗",
        "教我在上海和出租车司机聊天的话题，比如美食和生活"
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            // Welcome Text
            VStack(spacing: 12) {
                Text("欢迎使用问问")
                    .font(.largeTitle)
                    .bold()
                
                Text("您的中文学习助手")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            // New Chat Button
            Button(action: { chatStore.createNewSession() }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("开始新对话")
                }
                .font(.headline)
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
            }
            
            // Conversation Starters
            VStack(spacing: 16) {
                Text("试试这些话题：")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 12) {
                    ForEach(conversationStarters, id: \.self) { starter in
                        Button(action: {
                            startNewConversation(with: starter)
                        }) {
                            Text(starter)
                                .font(.body)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.gray.opacity(0.1))
                                )
                                .overlay(
                                    Capsule()
                                        .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.top, 20)
        }
        .padding()
    }
    
    private func startNewConversation(with starter: String) {
        let newSession = chatStore.createNewSession()
        guard var session = newSession else { return }
        
        // Create and add the user message
        let userMessage = ChatMessage(role: .user, content: starter)
        session.addMessage(userMessage)
        chatStore.updateCurrentSession(session)
        
        // Send the message to the API
        Task {
            do {
                let response = try await APIManager.shared.sendMessage(messages: session.messages)
                var updatedSession = session
                updatedSession.addMessage(response)
                await MainActor.run {
                    chatStore.updateCurrentSession(updatedSession)
                }
            } catch {
                print("Error sending message: \(error)")
            }
        }
    }
} 