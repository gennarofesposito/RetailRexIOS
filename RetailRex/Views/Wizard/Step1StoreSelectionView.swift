import SwiftUI

public struct Step1StoreSelectionView: View {
    @Binding public var visit: StoreVisit
    @ObservedObject private var repository = VisitRepository.shared
    @State private var showingStorePicker = false
    
    public init(visit: Binding<StoreVisit>) {
        self._visit = visit
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Card
                VStack(alignment: .leading, spacing: 6) {
                    Label("Store Visit Setup", systemImage: "mappin.and.ellipse")
                        .font(.title2.bold())
                        .foregroundColor(.rexNavy)
                    Text("Select or enter the store ID and visit timestamp to annotate all evidence records.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 4)
                
                // Store Picker Card
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("Selected Retail Store")
                            .font(.headline)
                        Spacer()
                        Button("Change Store") {
                            showingStorePicker = true
                        }
                        .font(.subheadline.bold())
                        .foregroundColor(.rexBlue)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(visit.storeName.isEmpty ? "Select a store..." : visit.storeName)
                                    .font(.title3.bold())
                                    .foregroundColor(.rexNavy)
                                HStack(spacing: 8) {
                                    Text("Store ID: \(visit.storeId)")
                                        .font(.caption.bold())
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color.rexBlue.opacity(0.12))
                                        .foregroundColor(.rexBlue)
                                        .cornerRadius(6)
                                }
                            }
                            Spacer()
                            Image(systemName: "building.2.crop.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.rexBlue)
                        }
                    }
                    .padding()
                    .background(Color.rexNavy.opacity(0.04))
                    .cornerRadius(12)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
                
                // Manual Entry Fields
                VStack(alignment: .leading, spacing: 16) {
                    Text("Visit Annotation Metadata")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Store ID")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        TextField("e.g. STR-8041", text: $visit.storeId)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Store Name")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        TextField("e.g. Sainsbury's Local", text: $visit.storeName)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Visit Date & Time")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        DatePicker("Visit Date", selection: $visit.visitDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.compact)
                            .padding(8)
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(8)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("RGE Executive Name / ID")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        HStack {
                            TextField("RGE Name", text: $visit.rgeName)
                                .textFieldStyle(.roundedBorder)
                            TextField("RGE ID", text: $visit.rgeId)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 120)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
            }
            .padding()
        }
        .sheet(isPresented: $showingStorePicker) {
            NavigationView {
                List(repository.stores) { store in
                    Button(action: {
                        visit.storeId = store.id
                        visit.storeName = store.name
                        showingStorePicker = false
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(store.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("\(store.id) • \(store.address)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: store.storeType.iconName)
                                .foregroundColor(.rexBlue)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .navigationTitle("Select Store")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingStorePicker = false }
                    }
                }
            }
        }
    }
}
