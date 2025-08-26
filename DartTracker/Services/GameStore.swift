import Foundation

final class GameStore: ObservableObject {
    @Published var currentGame: Game?
    @Published var recentGames: [Game] = []

    private let persistence = PersistenceService()
    private let checkout = CheckoutService()

    init() {
        recentGames = persistence.loadRecentGames()
    }

    func startNewGame(startingScore: StartingScore, playerNames: [String]) {
        let players = playerNames.map { Player(name: $0) }
        currentGame = Game(startingScore: startingScore, players: players)
    }

    func recordTurn(player: Player, darts: [Int]) {
        guard var game = currentGame else { return }
        let remainingBefore = game.remainingScore(for: player)
        let turn = Turn(playerId: player.id, darts: darts, startingRemaining: remainingBefore)
        game.turns.append(turn)
        currentGame = game
    }

    func finishCurrentGame() {
        guard let game = currentGame else { return }
        recentGames.insert(game, at: 0)
        recentGames = Array(recentGames.prefix(20))
        persistence.saveRecentGames(recentGames)
        currentGame = nil
    }

    func suggestedCheckout(for remaining: Int) -> [String] {
        checkout.suggestCheckout(for: remaining)
    }

    func suggestedCheckoutRoutes(for remaining: Int, limit: Int = 10) -> [CheckoutRoute] {
        checkout.suggestCheckouts(for: remaining, limit: limit)
    }
}


