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
                                    .id("\(message.id)-\(viewModel.showPinyin)")
                            }
                        }
                        .padding(.horizontal)
                    }
                    .onChange(of: viewModel.messages) { _, messages in
                        if let lastId = messages.last?.id {
                            withAnimation {
                                scrollViewProxy.scrollTo("\(lastId)-\(viewModel.showPinyin)", anchor: .bottom)
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
                        .submitLabel(.send)
                    
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
                Group {
                    if showPinyin {
                        MessageText(text: message.content)
                    } else {
                        Text(message.content)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(message.role == .user ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                .cornerRadius(16)
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(splitIntoLines(), id: \.self) { line in
                HStack(alignment: .center, spacing: 2) {
                    ForEach(Array(line.enumerated()), id: \.offset) { _, char in
                        CharacterWithPinyin(character: String(char))
                    }
                }
            }
        }
    }
    
    private func splitIntoLines() -> [String] {
        var lines: [String] = []
        var currentLine = ""
        let maxCharsPerLine = 15
        
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
                    .fixedSize(horizontal: true, vertical: false)
            }
            Text(character)
                .font(.body)
                .fixedSize(horizontal: true, vertical: false)
        }
    }
} 