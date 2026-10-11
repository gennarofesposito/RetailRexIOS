import SwiftUI

public struct Step3LCUView: View {
    @Binding public var audit: LCUAudit
    
    public init(audit: Binding<LCUAudit>) {
        self._audit = audit
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Label("2. Lottery Counter Unit (LCU)", systemImage: "square.grid.3x3.square")
                        .font(.title2.bold())
                        .foregroundColor(.rexNavy)
                    Text("Inspect the counter dispenser unit holding scratchcards. Capture 'Before' and 'After' photos ensuring all slots are fully stocked before departure.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Placement Check
                VStack(alignment: .leading, spacing: 14) {
                    Text("5) LCU Counter Placement")
                        .font(.headline)
                    
                    Picker("Placement Status", selection: $audit.placementStatus) {
                        ForEach(LCUPlacementStatus.allCases) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
                
                // Slot Status Check
                VStack(alignment: .leading, spacing: 14) {
                    Text("6) LCU Scratch-Card Slot Fill Status")
                        .font(.headline)
                    
                    Picker("Slot Capacity Status", selection: $audit.slotStateOnArrival) {
                        ForEach(LCUSlotState.allCases) { state in
                            Text(state.rawValue).tag(state)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Empty Slots Count")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                            Stepper("\(audit.emptySlotsCount) blank slots", value: $audit.emptySlotsCount, in: 0...audit.totalSlotsCount)
                        }
                    }
                    
                    Toggle(isOn: $audit.restockedBeforeDeparture) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Fully Restocked Before Departure")
                                .font(.subheadline.bold())
                            Text("Ensure all slots are 100% full before leaving store")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .tint(.rexEmerald)
                    
                    TextField("LCU Restock notes", text: $audit.notes)
                        .textFieldStyle(.roundedBorder)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
                
                // Before & After Photo Evidence
                VStack(alignment: .leading, spacing: 16) {
                    Text("LCU Before & After Photo Evidence")
                        .font(.headline)
                    Text("Take mandatory 'Before' arrival photo and 'After' departure photo showing fully restocked slots.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Before Photo Card
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                                .foregroundColor(.orange)
                            Text("BEFORE Photo (Arrival State)")
                                .font(.subheadline.bold())
                        }
                        
                        SinglePhotoSlot(photo: $audit.beforePhoto, category: .lcuBefore, placeholderText: "Capture BEFORE LCU Photo")
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(12)
                    
                    // After Photo Card
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                            Text("AFTER Photo (Fully Restocked State)")
                                .font(.subheadline.bold())
                        }
                        
                        SinglePhotoSlot(photo: $audit.afterPhoto, category: .lcuAfter, placeholderText: "Capture AFTER LCU Photo")
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(12)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
            }
            .padding()
        }
    }
}

public struct SinglePhotoSlot: View {
    @Binding public var photo: PhotoEvidence?
    public let category: PhotoCategory
    public let placeholderText: String
    
    @State private var showingActionSheet = false
    @State private var showingCameraPicker = false
    @State private var selectedSourceType: UIImagePickerController.SourceType = .camera
    
    public var body: some View {
        if let currentPhoto = photo {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.rexNavy.opacity(0.1))
                        .frame(width: 80, height: 60)
                    
                    if let uiImage = currentPhoto.loadedUIImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Image(systemName: category.iconName)
                            .font(.title2)
                            .foregroundColor(.rexBlue)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.rawValue)
                        .font(.subheadline.bold())
                    Text(currentPhoto.caption.isEmpty ? "Evidence captured" : currentPhoto.caption)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Button("Retake") {
                    showingActionSheet = true
                }
                .font(.caption.bold())
                .foregroundColor(.rexBlue)
            }
            .confirmationDialog("Retake Photo Evidence", isPresented: $showingActionSheet, titleVisibility: .visible) {
                Button("Take Photo with Camera") {
                    selectedSourceType = .camera
                    showingCameraPicker = true
                }
                Button("Choose from Photo Library") {
                    selectedSourceType = .photoLibrary
                    showingCameraPicker = true
                }
                Button("Simulate Sample Photo") {
                    addMockPhoto()
                }
                Button("Remove Photo", role: .destructive) {
                    photo = nil
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showingCameraPicker) {
                CameraPickerView(sourceType: selectedSourceType) { capturedImage in
                    processCapturedRealPhoto(capturedImage)
                }
            }
        } else {
            Button(action: { showingActionSheet = true }) {
                HStack {
                    Spacer()
                    Label(placeholderText, systemImage: "camera.fill")
                        .font(.subheadline.bold())
                        .foregroundColor(.rexBlue)
                    Spacer()
                }
                .padding(.vertical, 14)
                .background(Color.rexBlue.opacity(0.08))
                .cornerRadius(10)
            }
            .confirmationDialog("Capture LCU Photo", isPresented: $showingActionSheet, titleVisibility: .visible) {
                Button("Take Photo with Camera") {
                    selectedSourceType = .camera
                    showingCameraPicker = true
                }
                Button("Choose from Photo Library") {
                    selectedSourceType = .photoLibrary
                    showingCameraPicker = true
                }
                Button("Simulate Sample Photo") {
                    addMockPhoto()
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showingCameraPicker) {
                CameraPickerView(sourceType: selectedSourceType) { capturedImage in
                    processCapturedRealPhoto(capturedImage)
                }
            }
        }
    }
    
    private func processCapturedRealPhoto(_ image: UIImage) {
        guard let jpegData = image.jpegData(compressionQuality: 0.7) else { return }
        let base64String = jpegData.base64EncodedString()
        
        photo = PhotoEvidence(
            category: category,
            localImageData: base64String,
            caption: "\(category.rawValue) captured via device camera."
        )
    }
    
    private func addMockPhoto() {
        photo = PhotoEvidence(
            category: category,
            localImageName: "mock_\(category.rawValue.lowercased())",
            caption: category == .lcuBefore ? "LCU state upon arrival." : "LCU restocked 100% full before departure."
        )
    }
}
