import Foundation
import UIKit

public enum PhotoCategory: String, Codable, CaseIterable, Identifiable {
    case playstationContext = "PlayStation Context"
    case playstationHoppers = "PlayStation Hoppers"
    case lcuBefore = "LCU Before"
    case lcuAfter = "LCU After"
    case terminal = "Terminal & Scanner"
    case windowPromotions = "Window & Shop POS"
    case other = "Other Store POS"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .playstationContext: return "sparkles.tv"
        case .playstationHoppers: return "tray.2.fill"
        case .lcuBefore: return "photo.on.rectangle.angled"
        case .lcuAfter: return "checkmark.seal.fill"
        case .terminal: return "display"
        case .windowPromotions: return "window.vertical.closed"
        case .other: return "camera.fill"
        }
    }
}

public struct PhotoEvidence: Identifiable, Codable, Hashable {
    public var id: String
    public var category: PhotoCategory
    public var localImageName: String? // Name of local asset or mock image
    public var localImageData: String? // Base64 encoded JPEG for local storage
    public var firebaseUrl: String? // Remote URL from Firebase Storage
    public var timestamp: Date
    public var caption: String
    
    public init(
        id: String = UUID().uuidString,
        category: PhotoCategory,
        localImageName: String? = nil,
        localImageData: String? = nil,
        firebaseUrl: String? = nil,
        timestamp: Date = Date(),
        caption: String = ""
    ) {
        self.id = id
        self.category = category
        self.localImageName = localImageName
        self.localImageData = localImageData
        self.firebaseUrl = firebaseUrl
        self.timestamp = timestamp
        self.caption = caption
    }
    
    /// Display URL string: prefers firebaseUrl if uploaded, falls back to local data/name
    public var effectiveUrlOrPath: String {
        if let firebaseUrl = firebaseUrl, !firebaseUrl.isEmpty {
            return firebaseUrl
        }
        if let localImageName = localImageName {
            return "local://\(localImageName)"
        }
        if localImageData != nil {
            return "device_camera://\(id)"
        }
        return "pending_upload://\(id)"
    }
    
    /// Helper property to load real captured UIImage from base64 string
    public var loadedUIImage: UIImage? {
        guard let base64 = localImageData, let data = Data(base64Encoded: base64) else {
            return nil
        }
        return UIImage(data: data)
    }
}
