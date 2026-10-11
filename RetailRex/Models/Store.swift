import Foundation

public enum StoreType: String, Codable, CaseIterable, Identifiable {
    case supermarket = "Supermarket"
    case convenience = "Convenience Store"
    case newsagent = "Newsagent / Tobacconist"
    case forecourt = "Petrol Forecourt"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .supermarket: return "cart.fill"
        case .convenience: return "basket.fill"
        case .newsagent: return "newspaper.fill"
        case .forecourt: return "fuelpump.fill"
        }
    }
}

public struct Store: Identifiable, Codable, Hashable {
    public var id: String // storeId e.g. STORE-98421
    public var name: String // e.g. Tesco Express - Victoria
    public var retailerName: String // Owner/Manager name
    public var address: String
    public var storeType: StoreType
    public var phone: String
    public var lastVisitDate: Date?
    public var lastComplianceScore: Double?
    
    public init(
        id: String,
        name: String,
        retailerName: String,
        address: String,
        storeType: StoreType,
        phone: String,
        lastVisitDate: Date? = nil,
        lastComplianceScore: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.retailerName = retailerName
        self.address = address
        self.storeType = storeType
        self.phone = phone
        self.lastVisitDate = lastVisitDate
        self.lastComplianceScore = lastComplianceScore
    }
    
    public static var sampleStores: [Store] {
        return [
            Store(
                id: "STR-8041",
                name: "Sainsbury's Local - High St",
                retailerName: "Marcus Vance",
                address: "88 High Street, London EC1A 1BB",
                storeType: .convenience,
                phone: "+44 20 7946 0912",
                lastVisitDate: Date().addingTimeInterval(-86400 * 5),
                lastComplianceScore: 94.0
            ),
            Store(
                id: "STR-9210",
                name: "Londis Express - Piccadilly",
                retailerName: "Rajesh Patel",
                address: "14 Coventry Street, London W1D 7DH",
                storeType: .convenience,
                phone: "+44 20 7946 0451",
                lastVisitDate: Date().addingTimeInterval(-86400 * 12),
                lastComplianceScore: 82.5
            ),
            Store(
                id: "STR-7734",
                name: "BP Connect Forecourt",
                retailerName: "Sarah Jenkins",
                address: "420 Commercial Road, London E1 0BL",
                storeType: .forecourt,
                phone: "+44 20 7946 0889",
                lastVisitDate: Date().addingTimeInterval(-86400 * 20),
                lastComplianceScore: 78.0
            ),
            Store(
                id: "STR-6502",
                name: "Asda Superstore - Clapham",
                retailerName: "David O'Connor",
                address: "20 Clapham High St, London SW4 7UR",
                storeType: .supermarket,
                phone: "+44 20 7946 0123",
                lastVisitDate: Date().addingTimeInterval(-86400 * 2),
                lastComplianceScore: 98.0
            ),
            Store(
                id: "STR-5419",
                name: "Premier Corner News",
                retailerName: "Amina Khan",
                address: "15 Baker Street, London NW1 4FA",
                storeType: .newsagent,
                phone: "+44 20 7946 0777",
                lastVisitDate: Date().addingTimeInterval(-86400 * 30),
                lastComplianceScore: 71.0
            )
        ]
    }
}
