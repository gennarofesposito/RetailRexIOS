import SwiftUI

public struct HopperStatusToggle: View {
    @Binding public var hoppers: [GameHopperState]
    
    public init(hoppers: Binding<[GameHopperState]>) {
        self._hoppers = hoppers
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "tray.2.fill")
                    .foregroundColor(.rexAmber)
                Text("PlayStation Playslip Hoppers (6 Games)")
                    .font(.headline)
                Spacer()
                Text("\(fullCount)/6 Full")
                    .font(.subheadline.bold())
                    .foregroundColor(fullCount == 6 ? .green : .orange)
            }
            
            Text("Verify each game payslip hopper is completely full:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                ForEach($hoppers) { $hopper in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(hopper.gameName)
                                .font(.subheadline.bold())
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(hopper.isFull ? Color.green : Color.red)
                                    .frame(width: 8, height: 8)
                                Text(hopper.isFull ? "Full (100%)" : "Depleted / Low Stock")
                                    .font(.caption2)
                                    .foregroundColor(hopper.isFull ? .green : .red)
                            }
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $hopper.isFull)
                            .labelsHidden()
                            .tint(.rexBlue)
                            .onChange(of: hopper.isFull) { _, newValue in
                                hopper.fillPercentage = newValue ? 100 : 30
                            }
                    }
                    .padding(10)
                    .background(hopper.isFull ? Color.green.opacity(0.06) : Color.red.opacity(0.06))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(hopper.isFull ? Color.green.opacity(0.2) : Color.red.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(14)
    }
    
    private var fullCount: Int {
        hoppers.filter { $0.isFull }.count
    }
}
