import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showingWizard = false
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tabItem {
                        Label("Dashboard", systemImage: "rectangle.3.group.fill")
                    }
                    .tag(0)
                
                StoreDirectoryView()
                    .tabItem {
                        Label("Stores", systemImage: "building.2.fill")
                    }
                    .tag(1)
            }
            .tint(.rexBlue)
        }
        .sheet(isPresented: $showingWizard) {
            StoreVisitWizardView()
        }
    }
}
