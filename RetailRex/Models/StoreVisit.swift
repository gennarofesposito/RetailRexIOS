import Foundation

public enum VisitSyncStatus: String, Codable, CaseIterable, Identifiable {
    case draft = "Draft"
    case pendingSync = "Pending Sync"
    case uploadingPhotos = "Uploading Evidence"
    case synced = "Synced to Firebase"
    case syncFailed = "Sync Offline"
    
    public var id: String { rawValue }
    
    public var badgeColorName: String {
        switch self {
        case .draft: return "gray"
        case .pendingSync: return "orange"
        case .uploadingPhotos: return "blue"
        case .synced: return "green"
        case .syncFailed: return "red"
        }
    }
}

public struct StoreVisit: Identifiable, Codable, Hashable {
    public var id: String // e.g. VISIT-20261008-STR8041
    public var storeId: String
    public var storeName: String
    public var visitDate: Date
    public var rgeId: String
    public var rgeName: String
    
    public var playStationAudit: PlayStationAudit
    public var lcuAudit: LCUAudit
    public var terminalAudit: TerminalAudit
    public var retailerCheckIn: RetailerCheckIn
    
    public var syncStatus: VisitSyncStatus
    public var firebaseDocId: String?
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: String = "VISIT-\(ISO8601DateFormatter().string(from: Date()).prefix(10))-\(UUID().uuidString.prefix(6))",
        storeId: String,
        storeName: String,
        visitDate: Date = Date(),
        rgeId: String = "RGE-UK-402",
        rgeName: String = "Sarah Jenkins (RGE)",
        playStationAudit: PlayStationAudit = PlayStationAudit(),
        lcuAudit: LCUAudit = LCUAudit(),
        terminalAudit: TerminalAudit = TerminalAudit(),
        retailerCheckIn: RetailerCheckIn = RetailerCheckIn(),
        syncStatus: VisitSyncStatus = .draft,
        firebaseDocId: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.storeId = storeId
        self.storeName = storeName
        self.visitDate = visitDate
        self.rgeId = rgeId
        self.rgeName = rgeName
        self.playStationAudit = playStationAudit
        self.lcuAudit = lcuAudit
        self.terminalAudit = terminalAudit
        self.retailerCheckIn = retailerCheckIn
        self.syncStatus = syncStatus
        self.firebaseDocId = firebaseDocId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    /// Calculate overall store visit compliance percentage score across all checklist sections
    public var overallComplianceScore: Double {
        let psScore = playStationAudit.complianceScorePercentage
        let lcuScore = lcuAudit.complianceScorePercentage
        let termScore = terminalAudit.complianceScorePercentage
        
        let total = (psScore * 0.40) + (lcuScore * 0.35) + (termScore * 0.25)
        return min(100.0, max(0.0, total))
    }
    
    /// Collect all photo evidence across sections
    public var allEvidencePhotos: [PhotoEvidence] {
        var photos: [PhotoEvidence] = []
        photos.append(contentsOf: playStationAudit.photos)
        if let before = lcuAudit.beforePhoto { photos.append(before) }
        if let after = lcuAudit.afterPhoto { photos.append(after) }
        photos.append(contentsOf: terminalAudit.photos)
        return photos
    }
    
    /// Export store visit as formatted JSON string linking evidence photo URLs
    public func toJSONString() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        // Strip heavy localImageData from export preview to keep JSON readable and fast
        let stripped = self.strippedForFirestore()
        guard let data = try? encoder.encode(stripped),
              let jsonString = String(data: data, encoding: .utf8) else {
            return "{ \"error\": \"Failed to encode visit JSON\" }"
        }
        return jsonString
    }
    
    /// Returns a lightweight copy of the visit with raw base64 photo data stripped,
    /// keeping the document under 50KB to respect Firestore's 1MB limit.
    public func strippedForFirestore() -> StoreVisit {
        var copy = self
        copy.playStationAudit.photos = copy.playStationAudit.photos.map {
            var p = $0
            p.localImageData = nil
            return p
        }
        if var before = copy.lcuAudit.beforePhoto {
            before.localImageData = nil
            copy.lcuAudit.beforePhoto = before
        }
        if var after = copy.lcuAudit.afterPhoto {
            after.localImageData = nil
            copy.lcuAudit.afterPhoto = after
        }
        copy.terminalAudit.photos = copy.terminalAudit.photos.map {
            var p = $0
            p.localImageData = nil
            return p
        }
        return copy
    }
    
    public static var sampleCompletedVisit: StoreVisit {
        let psPhotos = [
            PhotoEvidence(
                category: .playstationContext,
                localImageName: "playstation_context",
                firebaseUrl: "https://firebasestorage.googleapis.com/v0/b/retailgrowth.firebasestorage.app/o/evidence%2FVISIT-STR-8041%2Fplaystation_context.jpg?alt=media",
                caption: "PlayStation located near main entrance with full clear sightlines."
            ),
            PhotoEvidence(
                category: .playstationHoppers,
                localImageName: "playstation_hoppers",
                firebaseUrl: "https://firebasestorage.googleapis.com/v0/b/retailgrowth.firebasestorage.app/o/evidence%2FVISIT-STR-8041%2Fplaystation_hoppers.jpg?alt=media",
                caption: "All 6 game playslip hoppers verified full."
            )
        ]
        
        let psAudit = PlayStationAudit(
            placementStatus: .optimal,
            placementNotes: "Positioned directly opposite entry door, high footfall area.",
            hoppers: GameHopperState.defaultSixGames,
            hasWorkingPen: true,
            hasUpToDatePosters: true,
            posterNotes: "Current £100M EuroMillions jackpot promo insert active.",
            photos: psPhotos
        )
        
        let beforePhoto = PhotoEvidence(
            category: .lcuBefore,
            localImageName: "lcu_before",
            firebaseUrl: "https://firebasestorage.googleapis.com/v0/b/retailgrowth.firebasestorage.app/o/evidence%2FVISIT-STR-8041%2Flcu_before.jpg?alt=media",
            caption: "LCU upon arrival: 3 blank slots detected in top row."
        )
        
        let afterPhoto = PhotoEvidence(
            category: .lcuAfter,
            localImageName: "lcu_after",
            firebaseUrl: "https://firebasestorage.googleapis.com/v0/b/retailgrowth.firebasestorage.app/o/evidence%2FVISIT-STR-8041%2Flcu_after.jpg?alt=media",
            caption: "LCU before departure: All 24 slots restocked and facing forward."
        )
        
        let lcuAudit = LCUAudit(
            placementStatus: .prominent,
            slotStateOnArrival: .minorBlanks,
            emptySlotsCount: 3,
            totalSlotsCount: 24,
            restockedBeforeDeparture: true,
            notes: "Restocked £3 and £5 scratchcards from under-counter reserve.",
            beforePhoto: beforePhoto,
            afterPhoto: afterPhoto
        )
        
        let termPhotos = [
            PhotoEvidence(
                category: .terminal,
                localImageName: "terminal_photo",
                firebaseUrl: "https://firebasestorage.googleapis.com/v0/b/retailgrowth.firebasestorage.app/o/evidence%2FVISIT-STR-8041%2Fterminal_photo.jpg?alt=media",
                caption: "Terminal online, 2D barcode scanner operational."
            )
        ]
        
        let terminalAudit = TerminalAudit(
            terminalStatus: .fullyFunctional,
            scannerStatus: .fullyFunctional,
            hardwareNotes: "Cleaned barcode scanner lens.",
            windowPostersPlaced: true,
            instorePOSPlaced: true,
            promotionalNotes: "Window poster double-sided display mounted.",
            photos: termPhotos
        )
        
        let checkIn = RetailerCheckIn(
            generalTradingNotes: "Retailer reports strong weekend draw ticket sales.",
            businessSentiment: .thriving,
            needsScratchcardStock: true,
            scratchcardStockDetails: "5 x Packs £5 Cash Word, 3 x Packs £2 Xmas Extra",
            needsGamePlayslips: false,
            playslipDetails: "",
            needsTerminalTillRolls: true,
            tillRollQuantity: 10,
            layoutImprovementIdeas: "Move till roll dispenser closer to operator for faster checkout times.",
            conversationSummary: "Spoke with store owner Marcus. Confirmed scratchcard delivery scheduled for Thursday. Provided 10 till rolls on site.",
            actionItems: [
                ActionItem(title: "Dispatch £5 Cash Word scratchcard stock", priority: .high, assignedTo: "Dispatch", isCompleted: false),
                ActionItem(title: "Follow up on window poster bracket replacement", priority: .medium, assignedTo: "RGE", isCompleted: false)
            ]
        )
        
        return StoreVisit(
            id: "VISIT-20261008-STR8041",
            storeId: "STR-8041",
            storeName: "Sainsbury's Local - High St",
            visitDate: Date().addingTimeInterval(-3600 * 2),
            rgeId: "RGE-UK-402",
            rgeName: "Sarah Jenkins (RGE)",
            playStationAudit: psAudit,
            lcuAudit: lcuAudit,
            terminalAudit: terminalAudit,
            retailerCheckIn: checkIn,
            syncStatus: .synced,
            firebaseDocId: "fb_visit_8041_abc123"
        )
    }
}
