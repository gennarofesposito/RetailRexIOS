import SwiftUI

public struct Step5RetailerCheckInView: View {
    @Binding public var checkIn: RetailerCheckIn
    @State private var newActionTitle: String = ""
    @State private var newActionPriority: ActionPriority = .medium
    @State private var newActionAssignee: String = "RGE"
    
    public init(checkIn: Binding<RetailerCheckIn>) {
        self._checkIn = checkIn
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Label("4. Retailer Conversation & Stock Needs", systemImage: "bubble.left.and.bubble.right.fill")
                        .font(.title2.bold())
                        .foregroundColor(.rexNavy)
                    Text("Check verbally with the retailer on trading, stock needs (scratchcards, playslips, till rolls), layout ideas, and actionable follow-ups.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // General Trading & Business Sentiment
                VStack(alignment: .leading, spacing: 14) {
                    Text("Retailer Trading Sentiment")
                        .font(.headline)
                    
                    Picker("Trading Sentiment", selection: $checkIn.businessSentiment) {
                        ForEach(BusinessSentiment.allCases) { sentiment in
                            Text("\(sentiment.emoji) \(sentiment.rawValue)").tag(sentiment)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("General Trading Feedback")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        TextEditor(text: $checkIn.generalTradingNotes)
                            .frame(height: 70)
                            .padding(4)
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
                
                // Consumables & Stock Replenishment Request
                VStack(alignment: .leading, spacing: 14) {
                    Text("Stock Replenishment Requests")
                        .font(.headline)
                    
                    // Scratchcard Stock
                    Toggle(isOn: $checkIn.needsScratchcardStock) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Scratch-Card Stock Needed?")
                                .font(.subheadline.bold())
                            Text("Request additional scratchcard packs for dispatch")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .tint(.rexBlue)
                    
                    if checkIn.needsScratchcardStock {
                        TextField("Scratchcard details (e.g. 5x £5 Cash Word, 3x £3 Cashspin)", text: $checkIn.scratchcardStockDetails)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    Divider()
                    
                    // Game Playslips
                    Toggle(isOn: $checkIn.needsGamePlayslips) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Game Playslips Needed?")
                                .font(.subheadline.bold())
                            Text("Lotto, EuroMillions, Set For Life playslip supply")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .tint(.rexBlue)
                    
                    if checkIn.needsGamePlayslips {
                        TextField("Playslip details (e.g. 2 bundles Lotto, 1 EuroMillions)", text: $checkIn.playslipDetails)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    Divider()
                    
                    // Terminal Till Roll
                    Toggle(isOn: $checkIn.needsTerminalTillRolls) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Lottery Terminal Till Roll Needed?")
                                .font(.subheadline.bold())
                            Text("Thermal paper rolls for terminal printer")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .tint(.rexBlue)
                    
                    if checkIn.needsTerminalTillRolls {
                        Stepper("Till Rolls Needed: \(checkIn.tillRollQuantity)", value: $checkIn.tillRollQuantity, in: 1...50)
                            .padding(8)
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
                
                // Layout Improvements & Typed Summary
                VStack(alignment: .leading, spacing: 14) {
                    Text("Layout Improvements & Typed Visit Summary")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ideas to Improve Layout of Lottery Materials")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        TextField("e.g. Move PlayStation closer to queue entrance for higher visibility", text: $checkIn.layoutImprovementIdeas)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Typed Summary of Retailer Conversation")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        TextEditor(text: $checkIn.conversationSummary)
                            .frame(height: 90)
                            .padding(4)
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
                
                // Action Items
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("Follow-Up Action Items")
                            .font(.headline)
                        Spacer()
                        Text("\(checkIn.actionItems.count) actions")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                    }
                    
                    ForEach($checkIn.actionItems) { $action in
                        HStack {
                            Toggle("", isOn: $action.isCompleted)
                                .labelsHidden()
                                .tint(.green)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(action.title)
                                    .font(.subheadline.bold())
                                    .strikethrough(action.isCompleted)
                                HStack(spacing: 6) {
                                    Text("Assigned: \(action.assignedTo)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Text("•")
                                        .font(.caption2)
                                    Text("Priority: \(action.priority.rawValue)")
                                        .font(.caption2.bold())
                                        .foregroundColor(action.priority == .high ? .red : .orange)
                                }
                            }
                            Spacer()
                            
                            Button(action: {
                                checkIn.actionItems.removeAll(where: { $0.id == action.id })
                            }) {
                                Image(systemName: "trash")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(10)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                    }
                    
                    // Add Action Row
                    VStack(spacing: 8) {
                        TextField("New action item title...", text: $newActionTitle)
                            .textFieldStyle(.roundedBorder)
                        
                        HStack {
                            Picker("Priority", selection: $newActionPriority) {
                                ForEach(ActionPriority.allCases) { p in
                                    Text(p.rawValue).tag(p)
                                }
                            }
                            .pickerStyle(.segmented)
                            
                            Button(action: {
                                guard !newActionTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                                let action = ActionItem(
                                    title: newActionTitle,
                                    priority: newActionPriority,
                                    assignedTo: newActionAssignee
                                )
                                checkIn.actionItems.append(action)
                                newActionTitle = ""
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.rexBlue)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
            }
            .padding()
        }
    }
}
