import Foundation

public enum PlacementStatus: String, Codable, CaseIterable, Identifiable {
    case optimal = "Optimal High-Traffic Area"
    case suboptimal = "Suboptimal / Poor Visibility"
    case obstructed = "Obstructed by Merchandise"
    case missing = "Missing / Not Installed"
    
    public var id: String { rawValue }
    
    public var badgeColorName: String {
        switch self {
        case .optimal: return "green"
        case .suboptimal: return "orange"
        case .obstructed: return "red"
        case .missing: return "purple"
        }
    }
}

public struct GameHopperState: Identifiable, Codable, Hashable {
    public var id: String
    public var gameName: String
    public var isFull: Bool
    public var fillPercentage: Int // 0 - 100%
    public var notes: String
    
    public init(id: String = UUID().uuidString, gameName: String, isFull: Bool = true, fillPercentage: Int = 100, notes: String = "") {
        self.id = id
        self.gameName = gameName
        self.isFull = isFull
        self.fillPercentage = fillPercentage
        self.notes = notes
    }
    
    public static var defaultSixGames: [GameHopperState] {
        return [
            GameHopperState(gameName: "Lotto", isFull: true, fillPercentage: 100),
            GameHopperState(gameName: "Lotto HotPicks", isFull: true, fillPercentage: 100),
            GameHopperState(gameName: "EuroMillions", isFull: true, fillPercentage: 100),
            GameHopperState(gameName: "EuroMillions HotPicks", isFull: true, fillPercentage: 100),
            GameHopperState(gameName: "Set For Life", isFull: true, fillPercentage: 100),
            GameHopperState(gameName: "Thunderball / Powerball", isFull: true, fillPercentage: 100)
        ]
    }
}

public struct PlayStationAudit: Codable, Hashable {
    public var placementStatus: PlacementStatus
    public var placementNotes: String
    public var hoppers: [GameHopperState]
    public var hasWorkingPen: Bool
    public var hasUpToDatePosters: Bool
    public var posterNotes: String
    public var photos: [PhotoEvidence]
    
    public init(
        placementStatus: PlacementStatus = .optimal,
        placementNotes: String = "",
        hoppers: [GameHopperState] = GameHopperState.defaultSixGames,
        hasWorkingPen: Bool = true,
        hasUpToDatePosters: Bool = true,
        posterNotes: String = "",
        photos: [PhotoEvidence] = []
    ) {
        self.placementStatus = placementStatus
        self.placementNotes = placementNotes
        self.hoppers = hoppers
        self.hasWorkingPen = hasWorkingPen
        self.hasUpToDatePosters = hasUpToDatePosters
        self.posterNotes = posterNotes
        self.photos = photos
    }
    
    /// Calculate percentage compliance for PlayStation audit
    public var complianceScorePercentage: Double {
        var points: Double = 0.0
        let totalPoints: Double = 4.0
        
        if placementStatus == .optimal { points += 1.0 }
        else if placementStatus == .suboptimal { points += 0.5 }
        
        let fullHoppersCount = hoppers.filter { $0.isFull || $0.fillPercentage >= 80 }.count
        points += (Double(fullHoppersCount) / Double(max(1, hoppers.count))) * 1.0
        
        if hasWorkingPen { points += 1.0 }
        if hasUpToDatePosters { points += 1.0 }
        
        return (points / totalPoints) * 100.0
    }
}
