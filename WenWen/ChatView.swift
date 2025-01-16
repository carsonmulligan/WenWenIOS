import SwiftUI

struct ChatView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    @State private var userInput: String = ""
    
    var body: some View {
        VStack {
            Toggle("显示拼音 (Show Pinyin)", isOn: $viewModel.showPinyin)
                .padding()
            
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(viewModel.messages) { message in
                            ChatRow(message: message, showPinyin: viewModel.showPinyin)
                                .id(message.id)
                        }
                    }
                }
                .onChange(of: viewModel.messages) { _ in
                    if let lastId = viewModel.messages.last?.id {
                        withAnimation {
                            scrollViewProxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }
            
            HStack {
                TextField("输入消息…", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        sendMessage()
                    }
                
                Button(action: sendMessage) {
                    Text("发送")
                }
                .padding(.leading, 8)
            }
            .padding()
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
        VStack(alignment: message.role == .user ? .trailing : .leading) {
            if showPinyin {
                Text(renderTextWithPinyin(message.content))
                    .padding()
                    .background(message.role == .user ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                    .cornerRadius(8)
            } else {
                Text(message.content)
                    .padding()
                    .background(message.role == .user ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)
        .padding(.horizontal)
    }
    
    private func renderTextWithPinyin(_ text: String) -> AttributedString {
        var attributedString = AttributedString("")
        for char in text {
            let s = String(char)
            if let pinyin = PinyinDictionary.shared.getPinyinTone(for: s) {
                var container = AttributedString(s)
                container.inlinePresentationIntent = .ruby
                let pinyinText = AttributedString("\n\(pinyin)\n")
                attributedString.append(pinyinText)
                attributedString.append(container)
            } else {
                attributedString.append(AttributedString(s))
            }
        }
        return attributedString
    }
} 