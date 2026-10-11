import SwiftUI

public struct Step4TerminalView: View {
    @Binding public var audit: TerminalAudit
    
    public init(audit: Binding<TerminalAudit>) {
        self._audit = audit
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Label("3. Terminal & Promotional POS", systemImage: "display")
                        .font(.title2.bold())
                        .foregroundColor(.rexNavy)
                    Text("Audit lottery terminal hardware, 2D barcode ticket scanner, and storefront promotional materials.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Hardware Health
                VStack(alignment: .leading, spacing: 14) {
                    Text("8) Lottery Terminal & Scanner Status")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Lottery Terminal Console")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        Picker("Terminal Status", selection: $audit.terminalStatus) {
                            ForEach(HardwareStatus.allCases) { status in
                                Text(status.rawValue).tag(status)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("2D Barcode Ticket Scanner")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        Picker("Scanner Status", selection: $audit.scannerStatus) {
                            ForEach(HardwareStatus.allCases) { status in
                                Text(status.rawValue).tag(status)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                    }
                    
                    TextField("Hardware & ticket scanner notes", text: $audit.hardwareNotes)
                        .textFieldStyle(.roundedBorder)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
                
                // Promotional Materials & Window Posters
                VStack(alignment: .leading, spacing: 14) {
                    Text("9) Promotional POS Placements")
                        .font(.headline)
                    
                    Toggle(isOn: $audit.windowPostersPlaced) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Storefront / Window Posters Placed")
                                .font(.subheadline.bold())
                            Text("Visible from street level")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .tint(.rexBlue)
                    
                    Divider()
                    
                    Toggle(isOn: $audit.instorePOSPlaced) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("In-Store Merchandising Placed")
                                .font(.subheadline.bold())
                            Text("Counter mats, shelf talkers, bollards")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .tint(.rexBlue)
                    
                    TextField("Promotional POS notes", text: $audit.promotionalNotes)
                        .textFieldStyle(.roundedBorder)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
                
                // Photo Evidence (1-2 photos of terminal & shop window/POS)
                CustomImagePicker(
                    category: .terminal,
                    title: "Terminal & POS Photo Evidence",
                    subtitle: "Take 1-2 photos of terminal setup and shop window promotional placements",
                    maxPhotos: 2,
                    photos: $audit.photos
                )
            }
            .padding()
        }
    }
}
