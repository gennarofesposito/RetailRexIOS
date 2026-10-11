import SwiftUI

public struct WizardStep: Identifiable, Equatable {
    public var id: Int
    public var title: String
    public var shortTitle: String
    public var iconName: String
}

public struct StepProgressBar: View {
    public let currentStepIndex: Int // 0-indexed
    public let totalSteps: Int
    public let steps: [WizardStep]
    
    public init(currentStepIndex: Int, totalSteps: Int = 6, steps: [WizardStep]) {
        self.currentStepIndex = currentStepIndex
        self.totalSteps = totalSteps
        self.steps = steps
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            // Header Title
            HStack {
                Text("STEP \(currentStepIndex + 1) OF \(totalSteps)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.rexBlue)
                
                Spacer()
                
                if currentStepIndex < steps.count {
                    Text(steps[currentStepIndex].title)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 4)
            
            // Step Dots & Lines
            HStack(spacing: 4) {
                ForEach(0..<totalSteps, id: \.self) { index in
                    HStack(spacing: 4) {
                        // Circle Indicator
                        ZStack {
                            Circle()
                                .fill(index <= currentStepIndex ? Color.rexBlue : Color.gray.opacity(0.3))
                                .frame(width: 28, height: 28)
                            
                            if index < currentStepIndex {
                                Image(systemName: "checkmark")
                                    .font(.caption2.bold())
                                    .foregroundColor(.white)
                            } else {
                                Text("\(index + 1)")
                                    .font(.caption2.bold())
                                    .foregroundColor(index == currentStepIndex ? .white : .secondary)
                            }
                        }
                        
                        // Connector Line
                        if index < totalSteps - 1 {
                            Rectangle()
                                .fill(index < currentStepIndex ? Color.rexBlue : Color.gray.opacity(0.3))
                                .frame(height: 3)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.rexNavy.opacity(0.04))
        .cornerRadius(12)
    }
}
