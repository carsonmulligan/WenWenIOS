import Foundation
import Security

class APIManager {
    private let baseUrl = "https://api.deepseek.com"
    private let modelName = "deepseek-chat"
    private let keychainService = "com.wenwenapp.apikey"
    private let keychainAccount = "deepseek"
    
    enum APIError: Error {
        case missingAPIKey
        case networkError(Error)
        case invalidResponse
    }
    
    private var apiKey: String? {
        // First try environment variable (development)
        if let envKey = ProcessInfo.processInfo.environment["DEEPSEEK_API_KEY"] {
            return envKey
        }
        
        // Then try keychain (production)
        return getAPIKeyFromKeychain()
    }
    
    private func getAPIKeyFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return key
    }
    
    func saveAPIKeyToKeychain(_ key: String) {
        let data = key.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: data
        ]
        
        // First try to delete any existing key
        SecItemDelete(query as CFDictionary)
        
        // Then save the new key
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Error saving API key to keychain: \(status)")
        }
    }

    func sendStreamingRequest(messages: [[String: String]],
                            onPartialResponse: @escaping (String) -> Void,
                            completion: @escaping () -> Void) {
        guard let apiKey = self.apiKey else {
            DispatchQueue.main.async {
                onPartialResponse("API密钥未设置。请在设置中配置API密钥。")
                completion()
            }
            return
        }
        
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
            if let error = error {
                DispatchQueue.main.async {
                    onPartialResponse("网络错误: \(error.localizedDescription)")
                    completion()
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    onPartialResponse("没有收到数据")
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
                    onPartialResponse("无法解析服务器响应")
                }
            }
            
            DispatchQueue.main.async {
                completion()
            }
        }
        
        task.resume()
    }
} 