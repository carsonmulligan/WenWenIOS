import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var chatStore: ChatStore
    
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
                            let newSession = chatStore.createNewSession()
                            if var session = newSession {
                                session.addMessage(ChatMessage(role: .user, content: starter))
                                chatStore.updateCurrentSession(session)
                            }
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
} 