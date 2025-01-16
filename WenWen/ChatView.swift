import SwiftUI

struct ChatView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    @State private var userInput: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Toggle("显示拼音 (Show Pinyin)", isOn: $viewModel.showPinyin)
                    .padding()
                
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                ChatRow(message: message, showPinyin: viewModel.showPinyin)
                                    .id(message.id)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let lastId = viewModel.messages.last?.id {
                            withAnimation {
                                scrollViewProxy.scrollTo(lastId, anchor: .bottom)
                            }
                        }
                    }
                }
                
                Divider()
                
                HStack {
                    TextField("输入消息...", text: $userInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            sendMessage()
                        }
                        .keyboardType(.default)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Button(action: sendMessage) {
                        Text("发送")
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("问问")
        }
    }
    
    private func sendMessage() {
        guard !userInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        viewModel.sendMessage(userInput)
        userInput = ""
    }
}

struct ChatRow: View {
    let message: ChatMessage
    let showPinyin: Bool
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading) {
                if showPinyin {
                    HStack(alignment: .bottom, spacing: 0) {
                        ForEach(Array(message.content.enumerated()), id: \.offset) { _, char in
                            CharacterWithPinyin(character: String(char))
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(message.role == .user ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                    .cornerRadius(16)
                } else {
                    Text(message.content)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(message.role == .user ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                        .cornerRadius(16)
                }
            }
            
            if message.role == .assistant {
                Spacer()
            }
        }
    }
}

struct CharacterWithPinyin: View {
    let character: String
    
    var body: some View {
        VStack(spacing: 2) {
            if let pinyin = PinyinDictionary.shared.getPinyinTone(for: character) {
                Text(pinyin)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Text(character)
                .font(.body)
        }
        .fixedSize()
        .padding(.horizontal, 1)
    }
} 