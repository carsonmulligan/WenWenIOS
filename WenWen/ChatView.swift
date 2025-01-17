import SwiftUI

struct ChatView: View {
    @EnvironmentObject var chatStore: ChatStore
    var session: ChatSession
    @State private var inputText = ""
    @State private var showPinyin = true
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(session.messages) { message in
                            MessageView(message: message, showPinyin: showPinyin)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: session.messages.count) { oldValue, newValue in
                    if let lastMessage = session.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            VStack(spacing: 8) {
                Toggle("显示拼音", isOn: $showPinyin)
                    .padding(.horizontal)
                
                HStack {
                    TextField("输入消息...", text: $inputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isFocused)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
            }
            .background(Color(.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(.systemGray4)),
                alignment: .top
            )
        }
    }
    
    private func sendMessage() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        var updatedSession = session
        let userMessage = ChatMessage(role: .user, content: trimmedText)
        updatedSession.addMessage(userMessage)
        chatStore.updateCurrentSession(updatedSession)
        
        inputText = ""
        isFocused = false
        
        // Send to API and handle response
        Task {
            do {
                let response = try await APIManager.shared.sendMessage(messages: updatedSession.messages)
                var sessionWithResponse = updatedSession
                sessionWithResponse.addMessage(response)
                await MainActor.run {
                    chatStore.updateCurrentSession(sessionWithResponse)
                }
            } catch {
                print("Error sending message: \(error)")
            }
        }
    }
}

struct MessageView: View {
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