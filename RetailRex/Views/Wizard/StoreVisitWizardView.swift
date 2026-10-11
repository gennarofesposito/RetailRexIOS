import SwiftUI

public struct StoreVisitWizardView: View {
    @StateObject private var viewModel: StoreVisitWizardViewModel
    @Environment(\.dismiss) private var dismiss
    private let initialStore: Store?
    
    public init(existingVisit: StoreVisit? = nil, selectedStore: Store? = nil) {
        self.initialStore = selectedStore
        _viewModel = StateObject(wrappedValue: StoreVisitWizardViewModel(existingVisit: existingVisit, selectedStore: selectedStore))
    }
    
    private let wizardSteps: [WizardStep] = [
        WizardStep(id: 0, title: "Store Details", shortTitle: "Store", iconName: "mappin.and.ellipse"),
        WizardStep(id: 1, title: "PlayStation Audit", shortTitle: "Stand", iconName: "sparkles.tv"),
        WizardStep(id: 2, title: "LCU Counter Unit", shortTitle: "LCU", iconName: "square.grid.3x3.square"),
        WizardStep(id: 3, title: "Terminal & POS", shortTitle: "Terminal", iconName: "display"),
        WizardStep(id: 4, title: "Retailer Check-In", shortTitle: "Talk", iconName: "bubble.left.and.bubble.right.fill"),
        WizardStep(id: 5, title: "Review & Submit", shortTitle: "Submit", iconName: "checkmark.seal.fill")
    ]
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top Progress Bar Header
                StepProgressBar(
                    currentStepIndex: viewModel.currentStepIndex,
                    totalSteps: 6,
                    steps: wizardSteps
                )
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Current Step Content View
                ZStack {
                    switch viewModel.currentStepIndex {
                    case 0:
                        Step1StoreSelectionView(visit: $viewModel.visit)
                    case 1:
                        Step2PlayStationView(audit: $viewModel.visit.playStationAudit)
                    case 2:
                        Step3LCUView(audit: $viewModel.visit.lcuAudit)
                    case 3:
                        Step4TerminalView(audit: $viewModel.visit.terminalAudit)
                    case 4:
                        Step5RetailerCheckInView(checkIn: $viewModel.visit.retailerCheckIn)
                    case 5:
                        Step6ReviewSubmitView(viewModel: viewModel)
                    default:
                        EmptyView()
                    }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                .animation(.easeInOut(duration: 0.25), value: viewModel.currentStepIndex)
                
                Divider()
                
                // Bottom Navigation Footer Bar
                HStack {
                    if viewModel.currentStepIndex > 0 {
                        Button(action: { viewModel.previousStep() }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Previous")
                            }
                            .font(.subheadline.bold())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.12))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: { viewModel.saveDraft() }) {
                        Text("Save Draft")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if viewModel.currentStepIndex < 5 {
                        Button(action: { viewModel.nextStep() }) {
                            HStack {
                                Text("Next Step")
                                Image(systemName: "chevron.right")
                            }
                            .font(.subheadline.bold())
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.rexBlue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
            }
            .navigationTitle("REX Store Visit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        viewModel.saveDraft()
                        dismiss()
                    }
                }
            }
            .alert("Visit Saved to Firebase", isPresented: $viewModel.isSubmittedSuccessfully) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Store visit data and evidence photos successfully recorded.")
            }
            .onAppear {
                if let store = initialStore {
                    viewModel.updateSelectedStore(store)
                }
            }
        }
    }
}
