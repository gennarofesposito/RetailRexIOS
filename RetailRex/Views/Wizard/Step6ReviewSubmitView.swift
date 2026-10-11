import SwiftUI

public struct Step6ReviewSubmitView: View {
    @ObservedObject public var viewModel: StoreVisitWizardViewModel
    @State private var showingJSONPreview = false
    
    public init(viewModel: StoreVisitWizardViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Label("5. Final Review & Firebase Submission", systemImage: "checkmark.seal.fill")
                        .font(.title2.bold())
                        .foregroundColor(.rexNavy)
                    Text("Review the completed store visit audit details, attached evidence photo URLs, and submit to Firebase.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Score Summary Hero Card
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.visit.storeName)
                                .font(.title3.bold())
                                .foregroundColor(.white)
                            Text("Store ID: \(viewModel.visit.storeId) • \(ISO8601DateFormatter().string(from: viewModel.visit.visitDate).prefix(10))")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        
                        VStack(spacing: 2) {
                            Text(String(format: "%.0f%%", viewModel.visit.overallComplianceScore))
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.rexGold)
                            Text("COMPLIANCE")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    Divider().background(Color.white.opacity(0.2))
                    
                    HStack {
                        Label("\(viewModel.visit.allEvidencePhotos.count) Photo Evidences", systemImage: "photo.stack")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                        Spacer()
                        Label("Firebase JSON Linked", systemImage: "icloud.and.arrow.up.fill")
                            .font(.caption.bold())
                            .foregroundColor(.rexGold)
                    }
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.rexNavy, Color.rexRoyal],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(18)
                .shadow(color: Color.rexNavy.opacity(0.2), radius: 10, x: 0, y: 5)
                
                // Checklist Summary Section
                VStack(alignment: .leading, spacing: 14) {
                    Text("Checklist Audit Summary")
                        .font(.headline)
                    
                    ReviewCheckRow(
                        title: "PlayStation Stand",
                        statusText: viewModel.visit.playStationAudit.placementStatus.rawValue,
                        isOk: viewModel.visit.playStationAudit.placementStatus == .optimal,
                        iconName: "sparkles.tv"
                    )
                    
                    ReviewCheckRow(
                        title: "6 Playslip Game Hoppers",
                        statusText: "\(viewModel.visit.playStationAudit.hoppers.filter { $0.isFull }.count)/6 Full",
                        isOk: viewModel.visit.playStationAudit.hoppers.allSatisfy { $0.isFull },
                        iconName: "tray.2.fill"
                    )
                    
                    ReviewCheckRow(
                        title: "PlayStation Pen & Posters",
                        statusText: "Pen: \(viewModel.visit.playStationAudit.hasWorkingPen ? "Yes" : "No") • Posters: \(viewModel.visit.playStationAudit.hasUpToDatePosters ? "Yes" : "No")",
                        isOk: viewModel.visit.playStationAudit.hasWorkingPen && viewModel.visit.playStationAudit.hasUpToDatePosters,
                        iconName: "pencil.and.outline"
                    )
                    
                    ReviewCheckRow(
                        title: "Lottery Counter Unit (LCU)",
                        statusText: "\(viewModel.visit.lcuAudit.placementStatus.rawValue) (\(viewModel.visit.lcuAudit.slotStateOnArrival.rawValue))",
                        isOk: viewModel.visit.lcuAudit.restockedBeforeDeparture,
                        iconName: "square.grid.3x3.square"
                    )
                    
                    ReviewCheckRow(
                        title: "Terminal & Barcode Scanner",
                        statusText: "\(viewModel.visit.terminalAudit.terminalStatus.rawValue) / \(viewModel.visit.terminalAudit.scannerStatus.rawValue)",
                        isOk: viewModel.visit.terminalAudit.terminalStatus == .fullyFunctional,
                        iconName: "display"
                    )
                    
                    ReviewCheckRow(
                        title: "Retailer Stock Requests",
                        statusText: stockSummaryText(viewModel.visit.retailerCheckIn),
                        isOk: true,
                        iconName: "shippingbox.fill"
                    )
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
                
                // Evidence Photos Grid
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Evidence Photos Summary")
                            .font(.headline)
                        Spacer()
                        Text("\(viewModel.visit.allEvidencePhotos.count) Attached")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.visit.allEvidencePhotos) { photo in
                                VStack(alignment: .leading, spacing: 4) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.rexNavy.opacity(0.08))
                                            .frame(width: 130, height: 90)
                                        
                                        VStack(spacing: 4) {
                                            Image(systemName: photo.category.iconName)
                                                .font(.title2)
                                                .foregroundColor(.rexBlue)
                                            Text(photo.category.rawValue)
                                                .font(.caption2.bold())
                                                .foregroundColor(.rexNavy)
                                        }
                                    }
                                    Text(photo.caption)
                                        .font(.caption2)
                                        .lineLimit(2)
                                        .frame(width: 130, alignment: .leading)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
                
                // JSON Preview Button & Sheet
                Button(action: { showingJSONPreview = true }) {
                    HStack {
                        Image(systemName: "curlybraces.square.fill")
                            .font(.title2)
                            .foregroundColor(.rexNavy)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Preview Firebase JSON Record")
                                .font(.subheadline.bold())
                                .foregroundColor(.primary)
                            Text("Inspect structured audit JSON with Firebase photo URLs")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "arrow.up.right.square.fill")
                            .font(.title3)
                            .foregroundColor(.rexBlue)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .sheet(isPresented: $showingJSONPreview) {
                    JSONExportView(visit: viewModel.visit)
                }
                
                // Submit Button
                Button(action: { viewModel.submitVisitToFirebase() }) {
                    HStack {
                        Spacer()
                        if viewModel.isSubmitting {
                            ProgressView()
                                .tint(.white)
                                .padding(.trailing, 8)
                            Text("Uploading Photos & Syncing to Firebase...")
                                .font(.headline)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "paperplane.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Submit Visit to Firebase")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(colors: [Color.rexBlue, Color.rexNavy], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(14)
                    .shadow(color: Color.rexBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(viewModel.isSubmitting)
            }
            .padding()
        }
    }
    
    private func stockSummaryText(_ checkIn: RetailerCheckIn) -> String {
        var items: [String] = []
        if checkIn.needsScratchcardStock { items.append("Scratchcards") }
        if checkIn.needsGamePlayslips { items.append("Playslips") }
        if checkIn.needsTerminalTillRolls { items.append("\(checkIn.tillRollQuantity) Till Rolls") }
        return items.isEmpty ? "No consumable stock requested" : items.joined(separator: ", ")
    }
}

public struct ReviewCheckRow: View {
    public let title: String
    public let statusText: String
    public let isOk: Bool
    public let iconName: String
    
    public var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.rexBlue)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(statusText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: isOk ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(isOk ? .green : .orange)
        }
        .padding(8)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
    }
}
