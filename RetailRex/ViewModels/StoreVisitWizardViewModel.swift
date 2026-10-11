import Foundation
import Combine

public class StoreVisitWizardViewModel: ObservableObject {
    @Published public var currentStepIndex: Int = 0
    @Published public var visit: StoreVisit
    @Published public var isSubmitting: Bool = false
    @Published public var submissionError: String? = nil
    @Published public var isSubmittedSuccessfully: Bool = false
    
    private let repository = VisitRepository.shared
    
    public init(existingVisit: StoreVisit? = nil, selectedStore: Store? = nil) {
        if let existing = existingVisit {
            self.visit = existing
        } else {
            let store = selectedStore ?? Store.sampleStores.first!
            self.visit = StoreVisit(
                storeId: store.id,
                storeName: store.name,
                visitDate: Date(),
                rgeId: "RGE-UK-402",
                rgeName: "Sarah Jenkins (RGE)"
            )
        }
    }
    
    public func updateSelectedStore(_ store: Store) {
        visit.storeId = store.id
        visit.storeName = store.name
    }
    
    public var currentStepTitle: String {
        switch currentStepIndex {
        case 0: return "Store Details"
        case 1: return "PlayStation Audit"
        case 2: return "LCU Counter Unit"
        case 3: return "Terminal & POS"
        case 4: return "Retailer Check-In"
        case 5: return "Review & Submit"
        default: return ""
        }
    }
    
    public func nextStep() {
        if currentStepIndex < 5 {
            saveDraft()
            currentStepIndex += 1
        }
    }
    
    public func previousStep() {
        if currentStepIndex > 0 {
            currentStepIndex -= 1
        }
    }
    
    public func saveDraft() {
        visit.syncStatus = .draft
        repository.saveVisit(visit)
    }
    
    public func submitVisitToFirebase() {
        isSubmitting = true
        submissionError = nil
        
        visit.syncStatus = .pendingSync
        repository.saveVisit(visit)
        
        repository.syncVisitToFirebase(visit) { [weak self] success in
            guard let self = self else { return }
            self.isSubmitting = false
            if success {
                self.isSubmittedSuccessfully = true
            } else {
                self.submissionError = "Saved locally. Sync queued for online connection."
                self.isSubmittedSuccessfully = true
            }
        }
    }
}
