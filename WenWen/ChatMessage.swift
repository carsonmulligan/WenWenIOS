import Foundation

enum MessageRole: String, Codable {
    case user
    case assistant
}

struct ChatMessage: Identifiable, Codable, Equatable {
    var id: UUID
    let role: MessageRole
    var content: String
    var isStreaming: Bool = false
    
    init(id: UUID = UUID(), role: MessageRole, content: String, isStreaming: Bool = false) {
        self.id = id
        self.role = role
        self.content = content
        self.isStreaming = isStreaming
    }
    
    func toAPIDict() -> [String: String] {
        return ["role": role.rawValue, "content": content]
    }
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id && 
               lhs.role == rhs.role && 
               lhs.content == rhs.content && 
               lhs.isStreaming == rhs.isStreaming
    }
} 