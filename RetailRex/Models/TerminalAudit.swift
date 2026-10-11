import Foundation

public enum HardwareStatus: String, Codable, CaseIterable, Identifiable {
    case fullyFunctional = "Fully Functional"
    case scannerDegraded = "Scanner Reading Issue"
    case terminalFaulty = "Terminal Faulty / Error Logged"
    case offline = "Offline / No Connectivity"
    
    public var id: String { rawValue }
}

public struct TerminalAudit: Codable, Hashable {
    public var terminalStatus: HardwareStatus
    public var scannerStatus: HardwareStatus
    public var hardwareNotes: String
    public var windowPostersPlaced: Bool
    public var instorePOSPlaced: Bool
    public var promotionalNotes: String
    public var photos: [PhotoEvidence]
    
    public init(
        terminalStatus: HardwareStatus = .fullyFunctional,
        scannerStatus: HardwareStatus = .fullyFunctional,
        hardwareNotes: String = "",
        windowPostersPlaced: Bool = true,
        instorePOSPlaced: Bool = true,
        promotionalNotes: String = "",
        photos: [PhotoEvidence] = []
    ) {
        self.terminalStatus = terminalStatus
        self.scannerStatus = scannerStatus
        self.hardwareNotes = hardwareNotes
        self.windowPostersPlaced = windowPostersPlaced
        self.instorePOSPlaced = instorePOSPlaced
        self.promotionalNotes = promotionalNotes
        self.photos = photos
    }
    
    public var complianceScorePercentage: Double {
        var points: Double = 0.0
        let total: Double = 4.0
        
        if terminalStatus == .fullyFunctional { points += 1.0 }
        if scannerStatus == .fullyFunctional { points += 1.0 }
        if windowPostersPlaced { points += 1.0 }
        if instorePOSPlaced { points += 1.0 }
        
        return (points / total) * 100.0
    }
}
