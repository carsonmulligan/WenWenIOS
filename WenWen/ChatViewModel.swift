import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var showPinyin: Bool = false
    
    private let localStorage = LocalStorage()
    private let apiManager = APIManager()
    
    init() {
        messages = localStorage.loadMessages()
    }
    
    func sendMessage(_ content: String) {
        let userMessage = ChatMessage(role: .user, content: content)
        messages.append(userMessage)
        localStorage.saveMessages(messages)
        
        let contextMessages = messages.map { $0.toAPIDict() }
        
        apiManager.sendStreamingRequest(messages: contextMessages) { [weak self] partialReply in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let last = self.messages.last, last.role == .assistant && last.isStreaming {
                    let updatedContent = last.content + partialReply
                    self.messages[self.messages.count - 1].content = updatedContent
                } else {
                    let assistantMessage = ChatMessage(role: .assistant, content: partialReply, isStreaming: true)
                    self.messages.append(assistantMessage)
                }
                self.localStorage.saveMessages(self.messages)
            }
        } completion: { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let lastIndex = self.messages.indices.last {
                    self.messages[lastIndex].isStreaming = false
                }
                self.localStorage.saveMessages(self.messages)
            }
        }
    }
} 