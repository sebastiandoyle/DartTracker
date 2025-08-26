import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            PlayView()
                .tabItem { Label("Play", systemImage: "target") }
            CheckoutLookupView()
                .tabItem { Label("Checkouts", systemImage: "number.circle") }
            VariationsView()
                .tabItem { Label("Variations", systemImage: "book") }
            HistoryView()
                .tabItem { Label("History", systemImage: "clock") }
        }
    }
}

struct RootTabView_Previews: PreviewProvider {
    static var previews: some View {
        RootTabView()
            .environmentObject(GameStore())
    }
}


