import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var store: GameStore

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.recentGames) { game in
                    VStack(alignment: .leading) {
                        Text("X01 \(game.startingScore.rawValue)")
                        Text(game.createdAt, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(game.players.map { $0.name }.joined(separator: ", "))
                            .font(.subheadline)
                    }
                }
            }
            .navigationTitle("History")
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView().environmentObject(GameStore())
    }
}


