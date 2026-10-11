import Foundation

public enum LCUPlacementStatus: String, Codable, CaseIterable, Identifiable {
    case prominent = "Prominently Placed at Checkout"
    case semiVisible = "Semi-Visible / Side Counter"
    case hidden = "Obstructed / Poor Visibility"
    case missing = "Not Installed / Removed"
    
    public var id: String { rawValue }
}

public enum LCUSlotState: String, Codable, CaseIterable, Identifiable {
    case allFilled = "100% Slots Full"
    case minorBlanks = "Minor Blanks (1-3 empty slots)"
    case majorBlanks = "Major Blanks (>3 empty slots)"
    case depleted = "Critically Depleted"
    
    public var id: String { rawValue }
}

public struct LCUAudit: Codable, Hashable {
    public var placementStatus: LCUPlacementStatus
    public var slotStateOnArrival: LCUSlotState
    public var emptySlotsCount: Int
    public var totalSlotsCount: Int
    public var restockedBeforeDeparture: Bool
    public var notes: String
    public var beforePhoto: PhotoEvidence?
    public var afterPhoto: PhotoEvidence?
    
    public init(
        placementStatus: LCUPlacementStatus = .prominent,
        slotStateOnArrival: LCUSlotState = .allFilled,
        emptySlotsCount: Int = 0,
        totalSlotsCount: Int = 24,
        restockedBeforeDeparture: Bool = true,
        notes: String = "",
        beforePhoto: PhotoEvidence? = nil,
        afterPhoto: PhotoEvidence? = nil
    ) {
        self.placementStatus = placementStatus
        self.slotStateOnArrival = slotStateOnArrival
        self.emptySlotsCount = emptySlotsCount
        self.totalSlotsCount = totalSlotsCount
        self.restockedBeforeDeparture = restockedBeforeDeparture
        self.notes = notes
        self.beforePhoto = beforePhoto
        self.afterPhoto = afterPhoto
    }
    
    public var complianceScorePercentage: Double {
        var points: Double = 0.0
        let total: Double = 3.0
        
        if placementStatus == .prominent { points += 1.0 }
        else if placementStatus == .semiVisible { points += 0.5 }
        
        if restockedBeforeDeparture { points += 1.0 }
        
        if slotStateOnArrival == .allFilled { points += 1.0 }
        else if slotStateOnArrival == .minorBlanks { points += 0.6 }
        else if slotStateOnArrival == .majorBlanks { points += 0.3 }
        
        return (points / total) * 100.0
    }
}
