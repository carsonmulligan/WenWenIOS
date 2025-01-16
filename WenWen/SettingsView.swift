import SwiftUI

struct SettingsView: View {
    @State private var apiKey: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    private let apiManager = APIManager()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("API设置")) {
                    SecureField("DeepSeek API密钥", text: $apiKey)
                    Button("保存API密钥") {
                        if apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            alertMessage = "API密钥不能为空"
                            showAlert = true
                            return
                        }
                        
                        apiManager.saveAPIKeyToKeychain(apiKey)
                        alertMessage = "API密钥已保存"
                        showAlert = true
                        apiKey = ""
                    }
                }
                
                Section(header: Text("说明")) {
                    Text("请在此处输入您的DeepSeek API密钥。API密钥将安全地存储在设备的钥匙串中。")
                        .font(.footnote)
                }
            }
            .navigationTitle("设置")
            .navigationBarItems(trailing: Button("完成") {
                dismiss()
            })
            .alert("提示", isPresented: $showAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
} 