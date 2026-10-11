import SwiftUI
import UIKit

public struct CustomImagePicker: View {
    public let category: PhotoCategory
    public let title: String
    public let subtitle: String
    public let maxPhotos: Int
    @Binding public var photos: [PhotoEvidence]
    
    @State private var showingActionSheet = false
    @State private var showingCameraPicker = false
    @State private var selectedSourceType: UIImagePickerController.SourceType = .camera
    
    public init(
        category: PhotoCategory,
        title: String = "Photo Evidence",
        subtitle: String = "Take 1-2 photos as evidence",
        maxPhotos: Int = 2,
        photos: Binding<[PhotoEvidence]>
    ) {
        self.category = category
        self.title = title
        self.subtitle = subtitle
        self.maxPhotos = maxPhotos
        self._photos = photos
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: category.iconName)
                    .foregroundColor(.rexBlue)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("\(photos.count)/\(maxPhotos)")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.rexBlue.opacity(0.1))
                    .foregroundColor(.rexBlue)
                    .cornerRadius(8)
            }
            
            // Photo Grid / Empty Slate
            if photos.isEmpty {
                Button(action: { showingActionSheet = true }) {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: "camera.circle.fill")
                                .font(.system(size: 38))
                                .foregroundColor(.rexBlue)
                            Text("Capture \(category.rawValue) Evidence")
                                .font(.subheadline.bold())
                                .foregroundColor(.primary)
                            Text("Tap to open camera or select photo")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 20)
                        Spacer()
                    }
                    .background(Color.rexNavy.opacity(0.03))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.rexBlue.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                    )
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(photos) { photo in
                            VStack(alignment: .leading, spacing: 6) {
                                ZStack(alignment: .topTrailing) {
                                    // Image Thumbnail Display (Real Captured UIImage vs Fallback)
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.rexNavy.opacity(0.08))
                                            .frame(width: 140, height: 110)
                                        
                                        if let uiImage = photo.loadedUIImage {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 140, height: 110)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                        } else {
                                            VStack(spacing: 4) {
                                                Image(systemName: photo.category.iconName)
                                                    .font(.title)
                                                    .foregroundColor(.rexBlue)
                                                Text(photo.category.rawValue)
                                                    .font(.caption2.bold())
                                                    .foregroundColor(.rexNavy)
                                                    .multilineTextAlignment(.center)
                                                    .padding(.horizontal, 4)
                                            }
                                        }
                                    }
                                    
                                    // Delete Button
                                    Button(action: {
                                        photos.removeAll(where: { $0.id == photo.id })
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                            .background(Circle().fill(Color.white))
                                    }
                                    .padding(6)
                                }
                                
                                Text(photo.caption.isEmpty ? "Evidence Captured" : photo.caption)
                                    .font(.caption2)
                                    .lineLimit(2)
                                    .foregroundColor(.secondary)
                                    .frame(width: 140, alignment: .leading)
                                
                                if let firebaseUrl = photo.firebaseUrl, !firebaseUrl.isEmpty {
                                    HStack(spacing: 2) {
                                        Image(systemName: "link")
                                        Text(firebaseUrl)
                                            .lineLimit(1)
                                            .truncationMode(.middle)
                                    }
                                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.green)
                                    .frame(width: 140, alignment: .leading)
                                }
                            }
                        }
                        
                        if photos.count < maxPhotos {
                            Button(action: { showingActionSheet = true }) {
                                VStack(spacing: 6) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.rexBlue)
                                    Text("Add Photo")
                                        .font(.caption.bold())
                                        .foregroundColor(.rexBlue)
                                }
                                .frame(width: 110, height: 110)
                                .background(Color.rexBlue.opacity(0.06))
                                .cornerRadius(10)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(14)
        .confirmationDialog("Capture Photo Evidence", isPresented: $showingActionSheet, titleVisibility: .visible) {
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
    
    private func processCapturedRealPhoto(_ image: UIImage) {
        guard let jpegData = image.jpegData(compressionQuality: 0.7) else { return }
        let base64String = jpegData.base64EncodedString()
        
        let newPhoto = PhotoEvidence(
            category: category,
            localImageData: base64String,
            caption: "\(category.rawValue) captured via device camera."
        )
        photos.append(newPhoto)
    }
    
    private func addMockPhoto() {
        let captions: [PhotoCategory: String] = [
            .playstationContext: "PlayStation stand placed prominently near main entrance.",
            .playstationHoppers: "Verified all 6 game playslip hoppers are fully stocked.",
            .lcuBefore: "LCU initial state: 3 empty slots observed on counter.",
            .lcuAfter: "LCU restored to 100% full capacity with all 24 slots filled.",
            .terminal: "Lottery terminal screen and 2D barcode scanner verified working.",
            .windowPromotions: "National Lottery promotional jackpot poster displayed in window.",
            .other: "In-store POS counter mat in good condition."
        ]
        
        let newPhoto = PhotoEvidence(
            category: category,
            localImageName: "evidence_\(category.rawValue.lowercased())",
            caption: captions[category] ?? "Store visit evidence captured."
        )
        photos.append(newPhoto)
    }
}
