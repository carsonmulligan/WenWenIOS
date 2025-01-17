import SwiftUI

class ChatStore: ObservableObject {
    @Published var sessions: [ChatSession] = []
    @Published var currentSession: ChatSession?
    
    private let sessionsFileName = "chat_sessions.json"
    
    init() {
        loadSessions()
    }
    
    @discardableResult
    func createNewSession() -> ChatSession? {
        let newSession = ChatSession()
        currentSession = newSession
        sessions.append(newSession)
        saveSessions()
        return newSession
    }
    
    func loadSession(_ id: UUID) {
        currentSession = sessions.first { $0.id == id }
    }
    
    func updateCurrentSession(_ session: ChatSession) {
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
            currentSession = session
            saveSessions()
        }
    }
    
    private func saveSessions() {
        guard let url = getDocumentsDirectory()?.appendingPathComponent(sessionsFileName) else { return }
        do {
            let data = try JSONEncoder().encode(sessions)
            try data.write(to: url)
        } catch {
            print("Error saving sessions: \(error)")
        }
    }
    
    private func loadSessions() {
        guard let url = getDocumentsDirectory()?.appendingPathComponent(sessionsFileName),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([ChatSession].self, from: data) else {
            return
        }
        sessions = decoded
    }
    
    private func getDocumentsDirectory() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
} 