import SwiftUI

public struct ComplianceBadge: View {
    public let score: Double
    
    public init(score: Double) {
        self.score = score
    }
    
    public var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.caption2.bold())
            Text(String(format: "%.0f%%", score))
                .font(.caption.bold())
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.15))
        .foregroundColor(color)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var color: Color {
        if score >= 90 { return .rexEmerald }
        if score >= 75 { return .rexBlue }
        if score >= 60 { return .rexAmber }
        return .rexRose
    }
    
    private var iconName: String {
        if score >= 90 { return "checkmark.seal.fill" }
        if score >= 75 { return "star.fill" }
        if score >= 60 { return "exclamationmark.triangle.fill" }
        return "xmark.octagon.fill"
    }
}

public struct SyncStatusBadge: View {
    public let status: VisitSyncStatus
    
    public init(status: VisitSyncStatus) {
        self.status = status
    }
    
    public var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(statusColor)
                .frame(width: 6, height: 6)
            Text(status.rawValue)
                .font(.caption2.bold())
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor.opacity(0.12))
        .cornerRadius(8)
    }
    
    private var statusColor: Color {
        switch status {
        case .synced: return .green
        case .uploadingPhotos, .pendingSync: return .orange
        case .draft: return .gray
        case .syncFailed: return .red
        }
    }
}
