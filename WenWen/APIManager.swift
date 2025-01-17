import Foundation

class APIManager {
    static let shared = APIManager()
    
    private init() {}
    
    private let baseUrl = "https://api.deepseek.com/v1/chat/completions"
    private let modelName = "deepseek-chat"
    
    private var apiKey: String {
        return Config.apiKey
    }
    
    func sendMessage(messages: [ChatMessage]) async throws -> ChatMessage {
        return try await withCheckedThrowingContinuation { continuation in
            var responseContent = ""
            
            sendStreamingRequest(
                messages: messages.map { ["role": $0.role.rawValue, "content": $0.content] },
                onPartialResponse: { content in
                    responseContent += content
                },
                completion: {
                    let response = ChatMessage(role: .assistant, content: responseContent)
                    continuation.resume(returning: response)
                }
            )
        }
    }
    
    func sendStreamingRequest(messages: [[String: String]],
                            onPartialResponse: @escaping (String) -> Void,
                            completion: @escaping () -> Void) {
        guard let url = URL(string: baseUrl) else { return }
        
        let requestBody: [String: Any] = [
            "model": modelName,
            "messages": messages,
            "stream": true
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: []) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error)")
                DispatchQueue.main.async {
                    onPartialResponse("网络错误: \(error.localizedDescription)")
                    completion()
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    onPartialResponse("无效的响应")
                    completion()
                }
                return
            }
            
            print("Response status code: \(httpResponse.statusCode)")
            
            guard let data = data else {
                DispatchQueue.main.async {
                    onPartialResponse("没有收到数据")
                    completion()
                }
                return
            }
            
            // Print raw response for debugging
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw response: \(rawResponse)")
            }
            
            if httpResponse.statusCode == 200 {
                // Handle streaming response
                let responseString = String(decoding: data, as: UTF8.self)
                let events = responseString.components(separatedBy: "data: ")
                
                for event in events {
                    guard !event.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }
                    guard event != "[DONE]" else { continue }
                    
                    if let jsonData = event.data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                       let choices = json["choices"] as? [[String: Any]],
                       let first = choices.first,
                       let delta = first["delta"] as? [String: Any],
                       let content = delta["content"] as? String {
                        DispatchQueue.main.async {
                            onPartialResponse(content)
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    onPartialResponse("服务器错误: \(httpResponse.statusCode)")
                }
            }
            
            DispatchQueue.main.async {
                completion()
            }
        }
        
        task.resume()
    }
} 