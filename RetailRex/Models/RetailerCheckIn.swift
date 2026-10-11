import Foundation

public enum BusinessSentiment: String, Codable, CaseIterable, Identifiable {
    case thriving = "Strong / Growth"
    case steady = "Steady / Average"
    case slow = "Slow / Footfall Down"
    case struggling = "Struggling / Issues"
    
    public var id: String { rawValue }
    
    public var emoji: String {
        switch self {
        case .thriving: return "🚀"
        case .steady: return "📈"
        case .slow: return "📉"
        case .struggling: return "⚠️"
        }
    }
}

public enum ActionPriority: String, Codable, CaseIterable, Identifiable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    
    public var id: String { rawValue }
    
    public var colorName: String {
        switch self {
        case .high: return "red"
        case .medium: return "orange"
        case .low: return "blue"
        }
    }
}

public struct ActionItem: Identifiable, Codable, Hashable {
    public var id: String
    public var title: String
    public var priority: ActionPriority
    public var assignedTo: String // RGE, Retailer, Dispatch
    public var isCompleted: Bool
    public var dueDate: Date?
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        priority: ActionPriority = .medium,
        assignedTo: String = "RGE",
        isCompleted: Bool = false,
        dueDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.priority = priority
        self.assignedTo = assignedTo
        self.isCompleted = isCompleted
        self.dueDate = dueDate
    }
}

public struct RetailerCheckIn: Codable, Hashable {
    public var generalTradingNotes: String
    public var businessSentiment: BusinessSentiment
    
    // Stock Needs
    public var needsScratchcardStock: Bool
    public var scratchcardStockDetails: String
    public var needsGamePlayslips: Bool
    public var playslipDetails: String
    public var needsTerminalTillRolls: Bool
    public var tillRollQuantity: Int
    
    // Layout Improvements & Conversation Summary
    public var layoutImprovementIdeas: String
    public var conversationSummary: String
    public var actionItems: [ActionItem]
    
    public init(
        generalTradingNotes: String = "",
        businessSentiment: BusinessSentiment = .steady,
        needsScratchcardStock: Bool = false,
        scratchcardStockDetails: String = "",
        needsGamePlayslips: Bool = false,
        playslipDetails: String = "",
        needsTerminalTillRolls: Bool = false,
        tillRollQuantity: Int = 0,
        layoutImprovementIdeas: String = "",
        conversationSummary: String = "",
        actionItems: [ActionItem] = []
    ) {
        self.generalTradingNotes = generalTradingNotes
        self.businessSentiment = businessSentiment
        self.needsScratchcardStock = needsScratchcardStock
        self.scratchcardStockDetails = scratchcardStockDetails
        self.needsGamePlayslips = needsGamePlayslips
        self.playslipDetails = playslipDetails
        self.needsTerminalTillRolls = needsTerminalTillRolls
        self.tillRollQuantity = tillRollQuantity
        self.layoutImprovementIdeas = layoutImprovementIdeas
        self.conversationSummary = conversationSummary
        self.actionItems = actionItems
    }
}
