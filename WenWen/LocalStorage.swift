import Foundation

class LocalStorage {
    private let storageKey = "WeWenChatMessages"
    
    func saveMessages(_ messages: [ChatMessage]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(messages)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Error saving messages: \(error)")
        }
    }
    
    func loadMessages() -> [ChatMessage] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return []
        }
        do {
            let decoder = JSONDecoder()
            let loaded = try decoder.decode([ChatMessage].self, from: data)
            return loaded
        } catch {
            print("Error loading messages: \(error)")
            return []
        }
    }
} 