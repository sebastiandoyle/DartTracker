import SwiftUI

struct PlayView: View {
    @EnvironmentObject var store: GameStore
    @State private var startingScore: StartingScore = .five01
    @State private var playerNames: [String] = ["Player 1", "Player 2"]
    @State private var currentPlayerIndex: Int = 0
    @State private var pendingDarts: [DartHit] = []

    var body: some View {
        NavigationStack {
            Group {
                if let game = store.currentGame {
                    gameView(game)
                } else {
                    setupView
                }
            }
            .navigationTitle("Play")
        }
    }

    private var setupView: some View {
        Form {
            Picker("Starting Score", selection: $startingScore) {
                ForEach(StartingScore.allCases) { s in
                    Text("\(s.rawValue)").tag(s)
                }
            }
            Section("Players") {
                ForEach(playerNames.indices, id: \.self) { i in
                    TextField("Name", text: Binding(
                        get: { playerNames[i] },
                        set: { playerNames[i] = $0 }
                    ))
                }
                HStack {
                    Button("Add Player") { if playerNames.count < 4 { playerNames.append("Player \(playerNames.count+1)") } }
                    Spacer()
                    Button("Remove Player") { if playerNames.count > 1 { _ = playerNames.popLast() } }
                }
            }
            Button(role: .none) {
                store.startNewGame(startingScore: startingScore, playerNames: playerNames)
            } label: {
                Text("Start Game")
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func gameView(_ game: Game) -> some View {
        let player = game.players[currentPlayerIndex % game.players.count]
        let remaining = game.remainingScore(for: player)
        let highlights = highlightTokens(for: remaining)

        return VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(player.name).font(.title2).bold()
                    Spacer()
                    Text("Remaining: \(remaining)").monospacedDigit().font(.title3)
                }
                if remaining <= 170 && remaining >= 2 {
                    let routes = store.suggestedCheckoutRoutes(for: remaining, limit: 5)
                    if !routes.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(routes) { r in
                                HStack {
                                    Text(r.tokens.joined(separator: ", "))
                                    Spacer()
                                    Text(formatPercent(r.probability))
                                        .monospacedDigit()
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)

            DartboardView(
                highlightTokens: highlights,
                lastHits: pendingDarts,
                onHit: { hit in
                    if pendingDarts.count < 3 {
                        pendingDarts.append(hit)
                    }
                }
            )
            .frame(maxWidth: .infinity)
            .padding()

            HStack(spacing: 12) {
                ForEach(pendingDarts) { h in
                    Text(h.token)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color(.secondarySystemBackground)))
                }
                Spacer()
                Button("Undo") {
                    _ = pendingDarts.popLast()
                }
                Button("Submit Turn") {
                    let total = pendingDarts.map { $0.value }
                    store.recordTurn(player: player, darts: total)
                    pendingDarts.removeAll()
                    currentPlayerIndex = (currentPlayerIndex + 1) % game.players.count
                }
                .buttonStyle(.borderedProminent)
                .disabled(pendingDarts.isEmpty)
            }
            .padding(.horizontal)

            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(game.players) { p in
                        HStack {
                            Text(p.name)
                            Spacer()
                            Text("\(game.remainingScore(for: p))")
                                .monospacedDigit()
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(.horizontal)
            }
            HStack {
                Button("Finish Game") { store.finishCurrentGame() }
                    .buttonStyle(.bordered)
            }
            .padding(.bottom)
        }
    }

    private func highlightTokens(for remaining: Int) -> Set<String> {
        let routes = store.suggestedCheckoutRoutes(for: remaining, limit: 1)
        guard let first = routes.first else { return [] }
        return Set(first.tokens)
    }

    private func formatPercent(_ p: Double) -> String {
        let pct = p * 100.0
        if pct >= 10 { return String(format: "%.0f%%", pct) }
        if pct >= 1 { return String(format: "%.1f%%", pct) }
        return String(format: "%.2f%%", pct)
    }
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        PlayView().environmentObject(GameStore())
    }
}


