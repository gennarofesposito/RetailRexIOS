import SwiftUI

public struct DashboardView: View {
    @StateObject private var repository = VisitRepository.shared
    @StateObject private var firebaseService = FirebaseService.shared
    
    @State private var showingWizard = false
    @State private var selectedStoreForWizard: Store? = nil
    @State private var selectedVisitForDetail: StoreVisit? = nil
    @State private var searchText = ""
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Greeting Banner
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("NATIONAL LOTTERY RGE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.rexGold)
                                .tracking(1.5)
                            Text("Retailer Experience (REX)")
                                .font(.title.bold())
                                .foregroundColor(.rexNavy)
                            Text("Field Store Visit & Audit Suite")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        
                        // Firebase Status Indicator
                        VStack(alignment: .trailing, spacing: 4) {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(firebaseService.isFirebaseConnected ? Color.green : Color.orange)
                                    .frame(width: 8, height: 8)
                                Text(firebaseService.isFirebaseConnected ? "Firebase Online" : "Local Caching")
                                    .font(.caption2.bold())
                                    .foregroundColor(firebaseService.isFirebaseConnected ? .green : .orange)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.secondary.opacity(0.12))
                            .cornerRadius(8)
                            
                            if repository.pendingSyncCount > 0 {
                                Button("Sync (\(repository.pendingSyncCount))") {
                                    repository.syncAllPendingVisits()
                                }
                                .font(.caption2.bold())
                                .foregroundColor(.rexBlue)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Main Start Visit Hero Card
                    Button(action: {
                        selectedStoreForWizard = nil
                        showingWizard = true
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 6) {
                                    Image(systemName: "play.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.rexGold)
                                    Text("FIELD AUDIT WIZARD")
                                        .font(.caption.bold())
                                        .foregroundColor(.rexGold)
                                }
                                Text("Start Store Visit")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                                Text("Step-by-step checklist for PlayStation, LCU, Terminal & Retailer Check-in with photo evidence.")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.85))
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            Image(systemName: "chevron.right.circle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        }
                        .padding(20)
                        .background(
                            LinearGradient(
                                colors: [Color.rexNavy, Color.rexRoyal, Color.rexBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: Color.rexNavy.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                    
                    // Metrics Overview Cards Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        MetricCard(
                            title: "Total Visits",
                            value: "\(repository.visits.count)",
                            subtitle: "Logged field audits",
                            iconName: "mappin.and.ellipse",
                            color: .rexBlue
                        )
                        MetricCard(
                            title: "Avg Compliance",
                            value: String(format: "%.0f%%", averageComplianceScore),
                            subtitle: "Merchandising score",
                            iconName: "checkmark.seal.fill",
                            color: .rexEmerald
                        )
                        MetricCard(
                            title: "Actions Logged",
                            value: "\(totalActionItemsCount)",
                            subtitle: "Follow-up items",
                            iconName: "list.bullet.clipboard.fill",
                            color: .rexAmber
                        )
                        MetricCard(
                            title: "Photos Linked",
                            value: "\(totalPhotosCount)",
                            subtitle: "Firebase evidence",
                            iconName: "photo.stack.fill",
                            color: .rexRoyal
                        )
                    }
                    .padding(.horizontal)
                    
                    // Recent Store Visits Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recent Store Visits")
                                .font(.title3.bold())
                                .foregroundColor(.rexNavy)
                            Spacer()
                            Text("\(filteredVisits.count) Visits")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        if filteredVisits.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "tray")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                Text("No Store Visits Found")
                                    .font(.headline)
                                Text("Tap 'Start Store Visit' to log your first store audit.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(16)
                            .padding(.horizontal)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(filteredVisits) { visit in
                                    SwipeableVisitCard(
                                        visit: visit,
                                        onTap: {
                                            selectedVisitForDetail = visit
                                        },
                                        onDelete: {
                                            withAnimation(.easeInOut(duration: 0.25)) {
                                                repository.deleteVisit(id: visit.id)
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingWizard) {
                StoreVisitWizardView(selectedStore: selectedStoreForWizard)
            }
            .sheet(item: $selectedVisitForDetail) { visit in
                VisitDetailView(visit: visit)
            }
        }
    }
    
    private var filteredVisits: [StoreVisit] {
        if searchText.isEmpty { return repository.visits }
        return repository.visits.filter {
            $0.storeName.localizedCaseInsensitiveContains(searchText) ||
            $0.storeId.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private var averageComplianceScore: Double {
        guard !repository.visits.isEmpty else { return 0.0 }
        let total = repository.visits.reduce(0.0) { $0 + $1.overallComplianceScore }
        return total / Double(repository.visits.count)
    }
    
    private var totalActionItemsCount: Int {
        repository.visits.reduce(0) { $0 + $1.retailerCheckIn.actionItems.count }
    }
    
    private var totalPhotosCount: Int {
        repository.visits.reduce(0) { $0 + $1.allEvidencePhotos.count }
    }
}

public struct MetricCard: View {
    public let title: String
    public let value: String
    public let subtitle: String
    public let iconName: String
    public let color: Color
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconName)
                    .font(.headline)
                    .foregroundColor(color)
                Spacer()
            }
            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.bold())
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}

public struct VisitCardRow: View {
    public let visit: StoreVisit
    
    public var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.rexNavy.opacity(0.08))
                    .frame(width: 46, height: 46)
                Image(systemName: "building.2.fill")
                    .font(.headline)
                    .foregroundColor(.rexBlue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(visit.storeName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    ComplianceBadge(score: visit.overallComplianceScore)
                }
                
                HStack(spacing: 8) {
                    Text("Store ID: \(visit.storeId)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(ISO8601DateFormatter().string(from: visit.visitDate).prefix(10))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 8) {
                    SyncStatusBadge(status: visit.syncStatus)
                    
                    Spacer()
                    
                    HStack(spacing: 3) {
                        Image(systemName: "photo.stack")
                            .font(.caption2)
                        Text("\(visit.allEvidencePhotos.count) photos")
                            .font(.caption2.bold())
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
}

public struct SwipeableVisitCard: View {
    public let visit: StoreVisit
    public let onTap: () -> Void
    public let onDelete: () -> Void
    
    @State private var offset: CGFloat = 0
    @State private var isSwiped: Bool = false
    
    private let deleteButtonWidth: CGFloat = 84
    
    public var body: some View {
        ZStack(alignment: .trailing) {
            // Delete Action Background Underlay
            HStack {
                Spacer()
                Button(role: .destructive, action: {
                    performDelete()
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "trash.fill")
                            .font(.title3.bold())
                        Text("Delete")
                            .font(.caption2.bold())
                    }
                    .foregroundColor(.white)
                    .frame(width: deleteButtonWidth)
                    .frame(maxHeight: .infinity)
                    .background(Color.red)
                    .cornerRadius(16)
                }
            }
            
            // Foreground Visit Card
            VisitCardRow(visit: visit)
                .contentShape(Rectangle())
                .offset(x: offset)
                .gesture(
                    DragGesture(minimumDistance: 15, coordinateSpace: .local)
                        .onChanged { gesture in
                            if gesture.translation.width < 0 {
                                offset = isSwiped ? max(-deleteButtonWidth - 40, -deleteButtonWidth + gesture.translation.width) : max(-deleteButtonWidth - 40, gesture.translation.width)
                            } else if isSwiped && gesture.translation.width > 0 {
                                offset = min(0, -deleteButtonWidth + gesture.translation.width)
                            }
                        }
                        .onEnded { gesture in
                            if gesture.translation.width < -150 {
                                // Full swipe-to-delete
                                performDelete()
                            } else if gesture.translation.width < -deleteButtonWidth / 2 {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                    offset = -deleteButtonWidth
                                    isSwiped = true
                                }
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            } else {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                    offset = 0
                                    isSwiped = false
                                }
                            }
                        }
                )
                .onTapGesture {
                    if isSwiped {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            offset = 0
                            isSwiped = false
                        }
                    } else {
                        onTap()
                    }
                }
        }
        .clipped()
    }
    
    private func performDelete() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(.easeInOut(duration: 0.25)) {
            offset = -500
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onDelete()
        }
    }
}
