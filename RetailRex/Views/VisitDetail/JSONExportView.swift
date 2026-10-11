import SwiftUI

public struct JSONExportView: View {
    public let visit: StoreVisit
    @Environment(\.dismiss) private var dismiss
    @State private var isCopied = false
    
    public init(visit: StoreVisit) {
        self.visit = visit
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Info
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Firebase Store Visit JSON Record")
                            .font(.headline)
                        Text("Linked to Firebase Storage evidence photo URLs")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                    Button(action: {
                        UIPasteboard.general.string = visit.toJSONString()
                        isCopied = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            isCopied = false
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                            Text(isCopied ? "Copied!" : "Copy JSON")
                        }
                        .font(.caption.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.rexBlue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                
                // Code ScrollView
                ScrollView {
                    Text(visit.toJSONString())
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.green)
                }
                .background(Color.black.opacity(0.9))
            }
            .navigationTitle("Firebase Visit Payload")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
