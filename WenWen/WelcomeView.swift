import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var chatStore: ChatStore
    
    var body: some View {
        VStack(spacing: 20) {
            Text("欢迎使用问问")
                .font(.largeTitle)
                .bold()
            
            Text("您的中文学习助手")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Button(action: { chatStore.createNewSession() }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("开始新对话")
                }
                .font(.headline)
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
            }
            .padding(.top, 30)
        }
        .padding()
    }
} 