import SwiftUI

public struct VisitDetailView: View {
    public let visit: StoreVisit
    @Environment(\.dismiss) private var dismiss
    @State private var showingJSONExport = false
    
    public init(visit: StoreVisit) {
        self.visit = visit
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Banner
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(visit.storeName)
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                                Text("Store ID: \(visit.storeId) • \(visit.rgeName)")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.85))
                                Text("Visit Date: \(ISO8601DateFormatter().string(from: visit.visitDate))")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            Spacer()
                            VStack(spacing: 4) {
                                ComplianceBadge(score: visit.overallComplianceScore)
                                SyncStatusBadge(status: visit.syncStatus)
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        LinearGradient(
                            colors: [Color.rexNavy, Color.rexRoyal],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(18)
                    
                    // Quick Action Buttons (JSON Export)
                    HStack {
                        Button(action: { showingJSONExport = true }) {
                            HStack {
                                Image(systemName: "curlybraces.square.fill")
                                Text("View Firebase JSON Payload")
                            }
                            .font(.subheadline.bold())
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Color.rexNavy.opacity(0.08))
                            .foregroundColor(.rexNavy)
                            .cornerRadius(10)
                        }
                    }
                    
                    // 1. PlayStation Audit Section
                    DetailSectionCard(title: "1. PlayStation Stand Audit", iconName: "sparkles.tv") {
                        VStack(alignment: .leading, spacing: 8) {
                            DetailRow(label: "Placement Status", value: visit.playStationAudit.placementStatus.rawValue)
                            if !visit.playStationAudit.placementNotes.isEmpty {
                                DetailRow(label: "Placement Notes", value: visit.playStationAudit.placementNotes)
                            }
                            
                            Divider()
                            Text("6 Playslip Game Hoppers Status:")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                            
                            ForEach(visit.playStationAudit.hoppers) { hopper in
                                HStack {
                                    Text(hopper.gameName)
                                        .font(.subheadline)
                                    Spacer()
                                    Text(hopper.isFull ? "Full (100%)" : "Depleted")
                                        .font(.caption.bold())
                                        .foregroundColor(hopper.isFull ? .green : .red)
                                }
                                .padding(6)
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(6)
                            }
                            
                            Divider()
                            DetailRow(label: "Lottery Pen Working", value: visit.playStationAudit.hasWorkingPen ? "Yes" : "No")
                            DetailRow(label: "Promotional Posters Current", value: visit.playStationAudit.hasUpToDatePosters ? "Yes" : "No")
                        }
                    }
                    
                    // 2. LCU Counter Unit Section
                    DetailSectionCard(title: "2. Lottery Counter Unit (LCU)", iconName: "square.grid.3x3.square") {
                        VStack(alignment: .leading, spacing: 8) {
                            DetailRow(label: "LCU Placement", value: visit.lcuAudit.placementStatus.rawValue)
                            DetailRow(label: "Slot Fill Status", value: visit.lcuAudit.slotStateOnArrival.rawValue)
                            DetailRow(label: "Empty Slots Count", value: "\(visit.lcuAudit.emptySlotsCount) blank slots")
                            DetailRow(label: "Restocked Departure", value: visit.lcuAudit.restockedBeforeDeparture ? "Yes (100% Full)" : "No")
                        }
                    }
                    
                    // 3. Terminal & Scanner Section
                    DetailSectionCard(title: "3. Terminal, Scanner & POS", iconName: "display") {
                        VStack(alignment: .leading, spacing: 8) {
                            DetailRow(label: "Terminal Status", value: visit.terminalAudit.terminalStatus.rawValue)
                            DetailRow(label: "2D Scanner Status", value: visit.terminalAudit.scannerStatus.rawValue)
                            DetailRow(label: "Window Posters Placed", value: visit.terminalAudit.windowPostersPlaced ? "Yes" : "No")
                            DetailRow(label: "In-Store POS Placed", value: visit.terminalAudit.instorePOSPlaced ? "Yes" : "No")
                        }
                    }
                    
                    // 4. Retailer Conversation & Action Items Section
                    DetailSectionCard(title: "4. Retailer Conversation & Actions", iconName: "bubble.left.and.bubble.right.fill") {
                        VStack(alignment: .leading, spacing: 8) {
                            DetailRow(label: "Business Trading Sentiment", value: "\(visit.retailerCheckIn.businessSentiment.emoji) \(visit.retailerCheckIn.businessSentiment.rawValue)")
                            
                            if !visit.retailerCheckIn.conversationSummary.isEmpty {
                                DetailRow(label: "Conversation Summary", value: visit.retailerCheckIn.conversationSummary)
                            }
                            
                            Divider()
                            Text("Requested Stock Replenishment:")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                            
                            if visit.retailerCheckIn.needsScratchcardStock {
                                DetailRow(label: "Scratchcards Needed", value: visit.retailerCheckIn.scratchcardStockDetails.isEmpty ? "Yes" : visit.retailerCheckIn.scratchcardStockDetails)
                            }
                            if visit.retailerCheckIn.needsGamePlayslips {
                                DetailRow(label: "Playslips Needed", value: visit.retailerCheckIn.playslipDetails.isEmpty ? "Yes" : visit.retailerCheckIn.playslipDetails)
                            }
                            if visit.retailerCheckIn.needsTerminalTillRolls {
                                DetailRow(label: "Till Rolls Needed", value: "\(visit.retailerCheckIn.tillRollQuantity) rolls")
                            }
                            if !visit.retailerCheckIn.needsScratchcardStock && !visit.retailerCheckIn.needsGamePlayslips && !visit.retailerCheckIn.needsTerminalTillRolls {
                                Text("No consumable stock requested.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            if !visit.retailerCheckIn.actionItems.isEmpty {
                                Divider()
                                Text("Follow-Up Action Items:")
                                    .font(.caption.bold())
                                    .foregroundColor(.secondary)
                                ForEach(visit.retailerCheckIn.actionItems) { action in
                                    HStack {
                                        Image(systemName: action.isCompleted ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(action.isCompleted ? .green : .gray)
                                        Text(action.title)
                                            .font(.subheadline)
                                        Spacer()
                                        Text(action.priority.rawValue)
                                            .font(.caption2.bold())
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(action.priority == .high ? Color.red.opacity(0.12) : Color.orange.opacity(0.12))
                                            .foregroundColor(action.priority == .high ? .red : .orange)
                                            .cornerRadius(6)
                                    }
                                }
                            }
                        }
                    }
                    
                    // 5. Attached Photo Evidences Gallery
                    DetailSectionCard(title: "Evidence Photos (\(visit.allEvidencePhotos.count))", iconName: "photo.stack.fill") {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(visit.allEvidencePhotos) { photo in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Label(photo.category.rawValue, systemImage: photo.category.iconName)
                                            .font(.subheadline.bold())
                                            .foregroundColor(.rexBlue)
                                        Spacer()
                                        Text(ISO8601DateFormatter().string(from: photo.timestamp).prefix(10))
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    if !photo.caption.isEmpty {
                                        Text(photo.caption)
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                    }
                                    
                                    HStack {
                                        Image(systemName: "link")
                                            .font(.caption2)
                                        Text(photo.effectiveUrlOrPath)
                                            .font(.system(size: 10, weight: .regular, design: .monospaced))
                                            .lineLimit(1)
                                    }
                                    .foregroundColor(.rexBlue)
                                    .padding(6)
                                    .background(Color.rexBlue.opacity(0.06))
                                    .cornerRadius(6)
                                }
                                .padding(10)
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Visit Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showingJSONExport) {
                JSONExportView(visit: visit)
            }
        }
    }
}

public struct DetailSectionCard<Content: View>: View {
    public let title: String
    public let iconName: String
    @ViewBuilder public let content: () -> Content
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: iconName)
                .font(.headline)
                .foregroundColor(.rexNavy)
            
            content()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}

public struct DetailRow: View {
    public let label: String
    public let value: String
    
    public var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
        }
    }
}
