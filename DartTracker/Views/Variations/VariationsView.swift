import SwiftUI

struct VariationsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("X01 (301/501/701)") {
                    Text("Start at \"X\" points and count down to zero. Must finish on a double (or bull).")
                }
                Section("Cricket") {
                    Text("Hit 15–20 and bull three times each. Close numbers and score points on open numbers.")
                }
                Section("Around the World") {
                    Text("Hit numbers sequentially 1 through 20, then bull to finish.")
                }
            }
            .navigationTitle("Variations")
        }
    }
}

struct VariationsView_Previews: PreviewProvider {
    static var previews: some View {
        VariationsView()
    }
}


