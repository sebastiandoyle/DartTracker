import SwiftUI

struct CheckoutLookupView: View {
    @EnvironmentObject var store: GameStore
    @State private var remaining: String = ""
    @State private var results: [CheckoutRoute] = []

    var body: some View {
        NavigationStack {
            Form {
                TextField("Remaining (2-170)", text: $remaining)
                    .keyboardType(.numberPad)
                Button("Suggest Checkouts") {
                    let value = Int(remaining) ?? 0
                    results = store.suggestedCheckoutRoutes(for: value, limit: 10)
                }
                if !results.isEmpty {
                    Section("Suggested Routes (highest probability first)") {
                        ForEach(results) { route in
                            HStack {
                                Text(route.tokens.joined(separator: ", "))
                                Spacer()
                                Text(formatPercent(route.probability))
                                    .monospacedDigit()
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Checkouts")
        }
    }

    private func formatPercent(_ p: Double) -> String {
        let pct = p * 100.0
        if pct >= 10 { return String(format: "%.0f%%", pct) }
        if pct >= 1 { return String(format: "%.1f%%", pct) }
        return String(format: "%.2f%%", pct)
    }
}

struct CheckoutLookupView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutLookupView().environmentObject(GameStore())
    }
}


