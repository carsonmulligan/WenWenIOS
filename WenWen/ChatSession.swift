import Foundation

struct ChatSession: Identifiable, Codable {
    let id: UUID
    var title: String
    var messages: [ChatMessage]
    var createdAt: Date
    var lastModified: Date
    
    init(id: UUID = UUID(), title: String = "新对话", messages: [ChatMessage] = [], createdAt: Date = Date(), lastModified: Date = Date()) {
        self.id = id
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
        self.lastModified = lastModified
    }
    
    mutating func generateTitle() {
        if let firstMessage = messages.first {
            let preview = String(firstMessage.content.prefix(20))
            title = preview + (firstMessage.content.count > 20 ? "..." : "")
        }
    }
    
    mutating func addMessage(_ message: ChatMessage) {
        messages.append(message)
        lastModified = Date()
        if messages.count == 1 {
            generateTitle()
        }
    }
} 