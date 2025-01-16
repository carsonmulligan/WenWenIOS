import Foundation

class APIManager {
    private let baseUrl = "https://api.deepseek.com"
    private let modelName = "deepseek-chat"
    
    // Get API key from environment or configuration
    private var apiKey: String {
        if let envKey = ProcessInfo.processInfo.environment["DEEPSEEK_API_KEY"] {
            return envKey
        }
        // For production, you might want to use a more secure storage method
        // like Keychain or configuration settings
        fatalError("DEEPSEEK_API_KEY not found in environment")
    }

    func sendStreamingRequest(messages: [[String: String]],
                            onPartialResponse: @escaping (String) -> Void,
                            completion: @escaping () -> Void) {
        guard let url = URL(string: baseUrl + "/v1/chat/completions") else { return }
        
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
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    onPartialResponse("（请求出错）")
                    completion()
                }
                return
            }
            
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
               let dict = jsonObject as? [String: Any],
               let choices = dict["choices"] as? [[String: Any]],
               let first = choices.first,
               let messageDict = first["message"] as? [String: Any],
               let content = messageDict["content"] as? String {
                
                let words = content.map { String($0) }
                for char in words {
                    DispatchQueue.main.async {
                        onPartialResponse(char)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    onPartialResponse("（无法解析服务器响应）")
                }
            }
            
            DispatchQueue.main.async {
                completion()
            }
        }
        
        task.resume()
    }
} 