import SwiftUI

public struct StoreDirectoryView: View {
    @StateObject private var repository = VisitRepository.shared
    @State private var searchText = ""
    @State private var selectedStoreForAudit: Store? = nil
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search store ID, name, address...", text: $searchText)
                        .textFieldStyle(.plain)
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(10)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Store List
                List(filteredStores) { store in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Text(store.name)
                                        .font(.headline)
                                        .foregroundColor(.rexNavy)
                                    Spacer()
                                    if let score = store.lastComplianceScore {
                                        ComplianceBadge(score: score)
                                    }
                                }
                                Text("\(store.id) • Retailer: \(store.retailerName)")
                                    .font(.caption.bold())
                                    .foregroundColor(.secondary)
                                Text(store.address)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            HStack(spacing: 4) {
                                Image(systemName: store.storeType.iconName)
                                Text(store.storeType.rawValue)
                            }
                            .font(.caption2.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.rexBlue.opacity(0.1))
                            .foregroundColor(.rexBlue)
                            .cornerRadius(6)
                            
                            Spacer()
                            
                            Button(action: {
                                selectedStoreForAudit = store
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "play.circle.fill")
                                    Text("Start Audit")
                                }
                                .font(.caption.bold())
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.rexNavy)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Store Directory")
            .sheet(item: $selectedStoreForAudit) { store in
                StoreVisitWizardView(selectedStore: store)
                    .id(store.id)
            }
        }
    }
    
    private var filteredStores: [Store] {
        if searchText.isEmpty { return repository.stores }
        return repository.stores.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.id.localizedCaseInsensitiveContains(searchText) ||
            $0.address.localizedCaseInsensitiveContains(searchText) ||
            $0.retailerName.localizedCaseInsensitiveContains(searchText)
        }
    }
}
