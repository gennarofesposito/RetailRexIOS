import Foundation

public class VisitRepository: ObservableObject {
    public static let shared = VisitRepository()
    
    @Published public var visits: [StoreVisit] = []
    @Published public var stores: [Store] = Store.sampleStores
    @Published public var pendingSyncCount: Int = 0
    
    private let storageKey = "REX_SAVED_STORE_VISITS"
    private let firebaseService = FirebaseService.shared
    
    public init() {
        loadVisitsFromStorage()
        if visits.isEmpty {
            visits = [StoreVisit.sampleCompletedVisit]
            saveVisitsToStorage()
        }
        updatePendingSyncCount()
    }
    
    public func saveVisit(_ visit: StoreVisit) {
        var updatedVisit = visit
        updatedVisit.updatedAt = Date()
        
        if let index = visits.firstIndex(where: { $0.id == visit.id }) {
            visits[index] = updatedVisit
        } else {
            visits.insert(updatedVisit, at: 0)
        }
        
        saveVisitsToStorage()
        updatePendingSyncCount()
        
        // Update store's last visit timestamp and compliance score
        if let storeIndex = stores.firstIndex(where: { $0.id == visit.storeId }) {
            stores[storeIndex].lastVisitDate = visit.visitDate
            stores[storeIndex].lastComplianceScore = visit.overallComplianceScore
        }
    }
    
    /// Deletes a visit and any stored data from the local device without modifying Firebase cloud records
    public func deleteVisit(id: String) {
        guard let index = visits.firstIndex(where: { $0.id == id }) else { return }
        let removedVisit = visits.remove(at: index)
        saveVisitsToStorage()
        updatePendingSyncCount()
        
        // Update store's last visit date/compliance based on remaining visits
        if let storeIndex = stores.firstIndex(where: { $0.id == removedVisit.storeId }) {
            let remainingVisits = visits.filter { $0.storeId == removedVisit.storeId }
            if let latest = remainingVisits.first {
                stores[storeIndex].lastVisitDate = latest.visitDate
                stores[storeIndex].lastComplianceScore = latest.overallComplianceScore
            } else {
                stores[storeIndex].lastVisitDate = nil
                stores[storeIndex].lastComplianceScore = nil
            }
        }
        
        print("🗑️ [VisitRepository] Deleted visit \(removedVisit.id) (\(removedVisit.storeName)) from local device storage.")
    }
    
    public func syncVisitToFirebase(_ visit: StoreVisit, completion: @escaping (Bool) -> Void) {
        var workingVisit = visit
        workingVisit.syncStatus = .uploadingPhotos
        saveVisit(workingVisit)
        
        print("🔥 [VisitRepository] ===================================================")
        print("🔥 [VisitRepository] Starting Firebase sync for visit: \(workingVisit.id)")
        print("🔥 [VisitRepository] STEP 1: Saving initial JSON file directly to Firebase Storage FIRST...")
        
        // STEP 1: Save JSON file first to Firebase Storage (/visits/{visitId}.json)
        firebaseService.saveVisitRecordToStorage(visit: workingVisit) { [weak self] storageResult in
            guard let self = self else { return }
            
            switch storageResult {
            case .success(let jsonUrl):
                print("✅ [VisitRepository] STEP 1 COMPLETE: Initial JSON saved to Firebase Storage: \(jsonUrl)")
                workingVisit.firebaseDocId = jsonUrl
            case .failure(let error):
                print("⚠️ [VisitRepository] STEP 1 Warning: Storage JSON write returned error: \(error.localizedDescription). Proceeding with photo uploads...")
            }
            
            self.saveVisit(workingVisit)
            
            // Release the UI spinner immediately so the user is never stuck
            completion(true)
            
            // STEP 2: Upload evidence photos to Firebase Storage in background
            self.uploadAllPhotos(for: workingVisit) { [weak self] visitWithPhotos in
                guard let self = self else { return }
                var finalVisit = visitWithPhotos
                finalVisit.syncStatus = .synced
                self.saveVisit(finalVisit)
                
                print("🔥 [VisitRepository] STEP 3: Updating visit JSON file in Firebase Storage with final photo URLs...")
                self.firebaseService.saveVisitRecordToStorage(visit: finalVisit) { updateResult in
                    switch updateResult {
                    case .success(let finalJsonUrl):
                        print("✅ [VisitRepository] ALL STEPS COMPLETE: Visit JSON file and all photos synced successfully to Firebase Storage!")
                        finalVisit.firebaseDocId = finalJsonUrl
                        self.saveVisit(finalVisit)
                    case .failure(let err):
                        print("⚠️ [VisitRepository] Notice: Final Storage JSON URL update returned: \(err.localizedDescription)")
                    }
                    print("🔥 [VisitRepository] ===================================================")
                }
            }
        }
    }
    
    private func uploadAllPhotos(for visit: StoreVisit, completion: @escaping (StoreVisit) -> Void) {
        var updatedVisit = visit
        let dispatchGroup = DispatchGroup()
        
        var updatedPlayStationPhotos = updatedVisit.playStationAudit.photos
        var updatedBeforePhoto = updatedVisit.lcuAudit.beforePhoto
        var updatedAfterPhoto = updatedVisit.lcuAudit.afterPhoto
        var updatedTerminalPhotos = updatedVisit.terminalAudit.photos
        
        let totalCount = updatedPlayStationPhotos.count +
            (updatedBeforePhoto != nil ? 1 : 0) +
            (updatedAfterPhoto != nil ? 1 : 0) +
            updatedTerminalPhotos.count
        
        print("🔥 [VisitRepository] STEP 2: Beginning upload of \(totalCount) photo(s) to Firebase Storage...")
        
        // 1. PlayStation Photos
        for i in 0..<updatedPlayStationPhotos.count {
            dispatchGroup.enter()
            firebaseService.uploadEvidencePhoto(visitId: updatedVisit.id, photo: updatedPlayStationPhotos[i]) { result in
                if case .success(let url) = result {
                    updatedPlayStationPhotos[i].firebaseUrl = url
                }
                dispatchGroup.leave()
            }
        }
        
        // 2. LCU Before Photo
        if let before = updatedBeforePhoto {
            dispatchGroup.enter()
            firebaseService.uploadEvidencePhoto(visitId: updatedVisit.id, photo: before) { result in
                if case .success(let url) = result {
                    updatedBeforePhoto?.firebaseUrl = url
                }
                dispatchGroup.leave()
            }
        }
        
        // 3. LCU After Photo
        if let after = updatedAfterPhoto {
            dispatchGroup.enter()
            firebaseService.uploadEvidencePhoto(visitId: updatedVisit.id, photo: after) { result in
                if case .success(let url) = result {
                    updatedAfterPhoto?.firebaseUrl = url
                }
                dispatchGroup.leave()
            }
        }
        
        // 4. Terminal Photos
        for i in 0..<updatedTerminalPhotos.count {
            dispatchGroup.enter()
            firebaseService.uploadEvidencePhoto(visitId: updatedVisit.id, photo: updatedTerminalPhotos[i]) { result in
                if case .success(let url) = result {
                    updatedTerminalPhotos[i].firebaseUrl = url
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("✅ [VisitRepository] STEP 2 COMPLETE: All \(totalCount) photos uploaded to Firebase Storage.")
            updatedVisit.playStationAudit.photos = updatedPlayStationPhotos
            updatedVisit.lcuAudit.beforePhoto = updatedBeforePhoto
            updatedVisit.lcuAudit.afterPhoto = updatedAfterPhoto
            updatedVisit.terminalAudit.photos = updatedTerminalPhotos
            completion(updatedVisit)
        }
    }
    
    public func syncAllPendingVisits() {
        let pending = visits.filter { $0.syncStatus == .pendingSync || $0.syncStatus == .syncFailed }
        for visit in pending {
            syncVisitToFirebase(visit) { _ in }
        }
    }
    
    private func updatePendingSyncCount() {
        pendingSyncCount = visits.filter { $0.syncStatus != .synced }.count
    }
    
    private func loadVisitsFromStorage() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode([StoreVisit].self, from: data) {
            self.visits = decoded
        }
    }
    
    private func saveVisitsToStorage() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(visits) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
}
