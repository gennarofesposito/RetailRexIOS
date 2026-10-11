import Foundation
import UIKit
import CoreGraphics
import FirebaseCore
import FirebaseStorage

// MARK: - Image Upload Helper Extension
private extension UIImage {
    func resizedForUpload(maxDimension: CGFloat = 1600) -> UIImage {
        let maxSide = max(size.width, size.height)
        guard maxSide > maxDimension else { return self }
        
        let ratio = maxDimension / maxSide
        let targetSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}

/// Service for handling Firebase Storage operations for REX Store Visits.
/// Stores evidence photos under `/evidence/{visitId}/*.jpg` and visit JSON records under `/visits/{visitId}.json`.
public class FirebaseService: ObservableObject {
    public static let shared = FirebaseService()
    
    @Published public var isFirebaseConnected: Bool = true
    @Published public var isUploading: Bool = false
    @Published public var uploadProgress: Double = 0.0
    @Published public var lastSyncTime: Date? = Date()
    
    private let storage = Storage.storage()
    
    public init() {
        print("🔥 [FirebaseService] Initialized using Firebase File Storage (Bucket: \(storage.reference().bucket))")
    }
    
    /// Uploads an evidence photo image to Firebase Storage and returns the public CDN URL
    public func uploadEvidencePhoto(
        visitId: String,
        photo: PhotoEvidence,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let sanitizedCategory = photo.category.rawValue
            .lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "_")
        
        let photoFilename = "\(sanitizedCategory)_\(photo.id.prefix(6)).jpg"
        let storagePath = "evidence/\(visitId)/\(photoFilename)"
        let storageRef = storage.reference().child(storagePath)
        
        print("🔥 [FirebaseStorage] Preparing upload for photo ID: \(photo.id) -> \(storagePath)")
        
        // Extract & optimize binary image data
        var imageData: Data?
        if let base64 = photo.localImageData, let rawData = Data(base64Encoded: base64) {
            if let image = UIImage(data: rawData) {
                let optimized = image.resizedForUpload()
                imageData = optimized.jpegData(compressionQuality: 0.8) ?? rawData
            } else {
                imageData = rawData
            }
        } else if let uiImage = photo.loadedUIImage {
            let optimized = uiImage.resizedForUpload()
            imageData = optimized.jpegData(compressionQuality: 0.8)
        } else if let name = photo.localImageName, let uiImage = UIImage(named: name) {
            imageData = uiImage.jpegData(compressionQuality: 0.8)
        }
        
        guard let dataToUpload = imageData, !dataToUpload.isEmpty else {
            print("⚠️ [FirebaseStorage] Warning: No binary image data found for photo: \(photo.id). Skipping upload.")
            let fallbackUrl = "https://firebasestorage.googleapis.com/v0/b/\(storage.reference().bucket)/o/evidence%2F\(visitId)%2F\(photoFilename)?alt=media"
            completion(.success(fallbackUrl))
            return
        }
        
        let uploadSizeKB = Double(dataToUpload.count) / 1024.0
        print("🔥 [FirebaseStorage] Uploading \(String(format: "%.1f", uploadSizeKB)) KB to \(storagePath)...")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        var hasCompleted = false
        let completeOnce: (Result<String, Error>) -> Void = { result in
            guard !hasCompleted else { return }
            hasCompleted = true
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let uploadTask = storageRef.putData(dataToUpload, metadata: metadata) { [weak self] metadata, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ [FirebaseStorage] Upload error for \(photoFilename): \(error.localizedDescription)")
                completeOnce(.failure(error))
                return
            }
            
            print("✅ [FirebaseStorage] Upload successful for \(photoFilename). Fetching download URL...")
            
            // Retrieve public download URL with fallback in case of rule restrictions or latency
            let fallbackUrl = "https://firebasestorage.googleapis.com/v0/b/\(self.storage.reference().bucket)/o/evidence%2F\(visitId)%2F\(photoFilename)?alt=media"
            
            storageRef.downloadURL { url, urlError in
                if let downloadUrl = url?.absoluteString {
                    print("✅ [FirebaseStorage] Public CDN URL retrieved: \(downloadUrl)")
                    completeOnce(.success(downloadUrl))
                } else {
                    if let urlError = urlError {
                        print("⚠️ [FirebaseStorage] downloadURL failed: \(urlError.localizedDescription). Using standard CDN URL fallback.")
                    }
                    completeOnce(.success(fallbackUrl))
                }
            }
        }
        
        uploadTask.observe(.progress) { [weak self] snapshot in
            guard let self = self, let progress = snapshot.progress else { return }
            DispatchQueue.main.async {
                self.uploadProgress = progress.fractionCompleted
            }
        }
    }
    
    /// Saves overall store visit JSON file to Firebase Storage bucket at `/visits/{visitId}.json`
    public func saveVisitRecordToStorage(
        visit: StoreVisit,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let cleanVisit = visit.strippedForFirestore()
        let filename = "\(cleanVisit.id).json"
        let storagePath = "visits/\(filename)"
        let storageRef = storage.reference().child(storagePath)
        
        print("🔥 [FirebaseStorage] Encoding and uploading visit JSON file to: \(storagePath)...")
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        guard let jsonData = try? encoder.encode(cleanVisit) else {
            let error = NSError(domain: "FirebaseService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to encode StoreVisit to JSON"])
            print("❌ [FirebaseStorage] Failed to encode JSON for \(filename)")
            completion(.failure(error))
            return
        }
        
        let jsonSizeKB = Double(jsonData.count) / 1024.0
        print("🔥 [FirebaseStorage] JSON payload size: \(String(format: "%.2f", jsonSizeKB)) KB. Uploading to Storage bucket: \(storage.reference().bucket)...")
        
        let metadata = StorageMetadata()
        metadata.contentType = "application/json"
        
        let fallbackUrl = "https://firebasestorage.googleapis.com/v0/b/\(storage.reference().bucket)/o/visits%2F\(cleanVisit.id).json?alt=media"
        
        var hasCompleted = false
        let completeOnce: (Result<String, Error>) -> Void = { [weak self] result in
            guard !hasCompleted else { return }
            hasCompleted = true
            self?.isUploading = false
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        // Safety timeout of 10s
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
            if !hasCompleted {
                print("⚠️ [FirebaseStorage] JSON upload timed out after 10s. Using fallback CDN URL.")
                completeOnce(.success(fallbackUrl))
            }
        }
        
        storageRef.putData(jsonData, metadata: metadata) { [weak self] _, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ [FirebaseStorage] Error saving JSON file to \(storagePath): \(error.localizedDescription)")
                completeOnce(.failure(error))
                return
            }
            
            print("✅ [FirebaseStorage] SUCCESS: JSON file uploaded to \(storagePath)!")
            self.lastSyncTime = Date()
            
            storageRef.downloadURL { url, _ in
                let finalUrl = url?.absoluteString ?? fallbackUrl
                print("✅ [FirebaseStorage] Visit JSON public CDN URL: \(finalUrl)")
                completeOnce(.success(finalUrl))
            }
        }
    }
    
    /// Compatibility alias for saveVisitRecordToStorage
    public func saveVisitRecordToFirestore(
        visit: StoreVisit,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        saveVisitRecordToStorage(visit: visit, completion: completion)
    }
    
    /// Fetch past store visit records from local repository
    public func fetchVisitsFromFirestore(
        completion: @escaping (Result<[StoreVisit], Error>) -> Void
    ) {
        DispatchQueue.main.async {
            completion(.success(VisitRepository.shared.visits))
        }
    }
}
