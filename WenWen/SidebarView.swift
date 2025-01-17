import SwiftUI

struct SidebarView: View {
    let sessions: [ChatSession]
    let onSessionSelect: (UUID) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sessions.sorted(by: { $0.lastModified > $1.lastModified })) { session in
                    Button(action: { onSessionSelect(session.id) }) {
                        VStack(alignment: .leading) {
                            Text(session.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(session.createdAt, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("历史对话")
            .navigationBarItems(trailing: Button("关闭") {
                dismiss()
            })
        }
    }
} 