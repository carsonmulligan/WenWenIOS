import Foundation

enum MessageRole: String, Codable {
    case user
    case assistant
}

struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    let role: MessageRole
    var content: String
    var isStreaming: Bool = false
    
    func toAPIDict() -> [String: String] {
        return ["role": role.rawValue, "content": content]
    }
} 