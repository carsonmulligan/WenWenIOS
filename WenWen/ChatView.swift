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
                Spacer(minLength: 60)
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading) {
                if showPinyin {
                    MessageText(text: message.content, showPinyin: true)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(message.role == .user ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                        .cornerRadius(16)
                } else {
                    Text(message.content)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(message.role == .user ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                        .cornerRadius(16)
                }
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.role == .user ? .trailing : .leading)
            
            if message.role == .assistant {
                Spacer(minLength: 60)
            }
        }
    }
}

struct MessageText: View {
    let text: String
    let showPinyin: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(splitIntoLines(), id: \.self) { line in
                HStack(alignment: .bottom, spacing: 2) {
                    ForEach(line.indices, id: \.self) { index in
                        CharacterWithPinyin(character: String(line[index]))
                    }
                }
            }
        }
    }
    
    private func splitIntoLines() -> [String] {
        var lines: [String] = []
        var currentLine = ""
        let maxCharsPerLine = 12 // Adjust this value based on your needs
        
        for char in text {
            if currentLine.count >= maxCharsPerLine {
                lines.append(currentLine)
                currentLine = ""
            }
            currentLine.append(char)
        }
        
        if !currentLine.isEmpty {
            lines.append(currentLine)
        }
        
        return lines
    }
}

struct CharacterWithPinyin: View {
    let character: String
    
    var body: some View {
        VStack(spacing: 1) {
            if let pinyin = PinyinDictionary.shared.getPinyinTone(for: character) {
                Text(pinyin)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            Text(character)
                .font(.body)
        }
        .fixedSize()
    }
} 