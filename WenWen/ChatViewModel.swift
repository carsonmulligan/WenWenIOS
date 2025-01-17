import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var showPinyin: Bool = true
    
    private var currentResponseContent: String = ""
    
    func sendMessage(_ text: String) {
        let userMessage = ChatMessage(role: .user, content: text)
        messages.append(userMessage)
        
        let messagesForAPI = messages.map { ["role": $0.role.rawValue, "content": $0.content] }
        
        currentResponseContent = ""
        APIManager.shared.sendStreamingRequest(
            messages: messagesForAPI,
            onPartialResponse: { [weak self] content in
                self?.handlePartialResponse(content)
            },
            completion: { [weak self] in
                self?.finalizeResponse()
            }
        )
    }
    
    private func handlePartialResponse(_ content: String) {
        currentResponseContent += content
        
        if let lastMessage = messages.last, lastMessage.role == .assistant {
            // Update existing assistant message
            var updatedMessages = messages
            updatedMessages[messages.count - 1] = ChatMessage(role: .assistant, content: currentResponseContent)
            messages = updatedMessages
        } else {
            // Add new assistant message
            messages.append(ChatMessage(role: .assistant, content: currentResponseContent))
        }
    }
    
    private func finalizeResponse() {
        // Ensure the final message is properly formatted
        if let lastMessage = messages.last, lastMessage.role == .assistant {
            var updatedMessages = messages
            updatedMessages[messages.count - 1] = ChatMessage(role: .assistant, content: currentResponseContent)
            messages = updatedMessages
        }
        currentResponseContent = ""
    }
} 