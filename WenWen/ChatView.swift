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
                    FlexibleRow(text: message.content, showPinyin: true)
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

struct FlexibleRow: View {
    let text: String
    let showPinyin: Bool
    
    var body: some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return GeometryReader { geometry in
            ZStack(alignment: .leading) {
                ForEach(generateCharacterViews(containerWidth: geometry.size.width), id: \.offset) { charView in
                    charView.view
                        .alignmentGuide(.leading) { dimension in
                            if abs(width - charView.width) > geometry.size.width {
                                width = 0
                                height -= charView.height
                            }
                            let result = width
                            if charView.isLastCharacter {
                                width = 0
                            } else {
                                width -= dimension.width
                            }
                            return result
                        }
                        .alignmentGuide(.top) { _ in
                            let result = height
                            if charView.isLastCharacter {
                                height = 0
                            }
                            return result
                        }
                }
            }
        }
    }
    
    private func generateCharacterViews(containerWidth: CGFloat) -> [(offset: Int, width: CGFloat, height: CGFloat, view: AnyView, isLastCharacter: Bool)] {
        var views: [(offset: Int, width: CGFloat, height: CGFloat, view: AnyView, isLastCharacter: Bool)] = []
        var currentWidth: CGFloat = 0
        
        for (index, char) in text.enumerated() {
            let charString = String(char)
            let view = CharacterWithPinyin(character: charString)
            let size = view.sizeThatFits(containerWidth)
            
            if currentWidth + size.width > containerWidth {
                currentWidth = 0
            }
            
            views.append((
                offset: index,
                width: size.width,
                height: size.height,
                view: AnyView(view),
                isLastCharacter: index == text.count - 1
            ))
            
            currentWidth += size.width
        }
        
        return views
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
    
    func sizeThatFits(_ width: CGFloat) -> CGSize {
        let estimatedWidth: CGFloat = 30  // Approximate width for a character + pinyin
        let estimatedHeight: CGFloat = 40  // Approximate height for character + pinyin
        return CGSize(width: estimatedWidth, height: estimatedHeight)
    }
} 