import SwiftUI

public struct Step2PlayStationView: View {
    @Binding public var audit: PlayStationAudit
    
    public init(audit: Binding<PlayStationAudit>) {
        self._audit = audit
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Step Title Header
                VStack(alignment: .leading, spacing: 6) {
                    Label("1. PlayStation Audit", systemImage: "sparkles.tv")
                        .font(.title2.bold())
                        .foregroundColor(.rexNavy)
                    Text("Audit the lottery-branded stand where customers complete paper playslips. Verify placement, 6 game hoppers, pen, and promotional posters.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Item 1: Placement Check
                VStack(alignment: .leading, spacing: 14) {
                    Text("1) PlayStation Placement in Store")
                        .font(.headline)
                    
                    Picker("Placement Status", selection: $audit.placementStatus) {
                        ForEach(PlacementStatus.allCases) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                    
                    TextField("Placement notes (e.g. Near entrance, good visibility)", text: $audit.placementNotes)
                        .textFieldStyle(.roundedBorder)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
                
                // Item 2: 6 Game Hoppers Check
                HopperStatusToggle(hoppers: $audit.hoppers)
                
                // Item 3 & 4: Pen & Promotional Slot-in Posters
                VStack(alignment: .leading, spacing: 14) {
                    Text("3 & 4) PlayStation Accessories & POS")
                        .font(.headline)
                    
                    Toggle(isOn: $audit.hasWorkingPen) {
                        HStack {
                            Image(systemName: "pencil.and.outline")
                                .foregroundColor(.rexBlue)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Lottery Pen Present & Tethered")
                                    .font(.subheadline.bold())
                                Text("Check pen is attached and working")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .tint(.rexBlue)
                    
                    Divider()
                    
                    Toggle(isOn: $audit.hasUpToDatePosters) {
                        HStack {
                            Image(systemName: "photo.stack.fill")
                                .foregroundColor(.rexBlue)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Up-to-Date Promotional Posters")
                                    .font(.subheadline.bold())
                                Text("Check slot-in jackpot/promo inserts are current")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .tint(.rexBlue)
                    
                    if !audit.hasUpToDatePosters {
                        TextField("Poster notes (e.g. Needs current EuroMillions jackpot insert)", text: $audit.posterNotes)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
                
                // Photo Evidence (1-2 photos of PlayStation)
                CustomImagePicker(
                    category: .playstationContext,
                    title: "PlayStation Photo Evidence",
                    subtitle: "Take 1-2 photos capturing PlayStation context in store, hoppers, pen & posters",
                    maxPhotos: 2,
                    photos: $audit.photos
                )
            }
            .padding()
        }
    }
}
