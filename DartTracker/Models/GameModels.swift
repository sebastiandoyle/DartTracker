import Foundation

enum GameMode: String, CaseIterable, Codable, Identifiable {
    case x01
    var id: String { rawValue }
}

enum StartingScore: Int, CaseIterable, Codable, Identifiable {
    case three01 = 301
    case five01 = 501
    case seven01 = 701
    var id: Int { rawValue }
}

struct Player: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

struct Turn: Identifiable, Codable {
    let id: UUID
    let playerId: UUID
    let darts: [Int]
    let total: Int
    let remainingAfter: Int

    init(id: UUID = UUID(), playerId: UUID, darts: [Int], startingRemaining: Int) {
        self.id = id
        self.playerId = playerId
        self.darts = darts
        self.total = darts.reduce(0, +)
        self.remainingAfter = max(0, startingRemaining - self.total)
    }
}

struct Game: Identifiable, Codable {
    let id: UUID
    var mode: GameMode
    var startingScore: StartingScore
    var players: [Player]
    var turns: [Turn]
    var createdAt: Date

    init(id: UUID = UUID(), mode: GameMode = .x01, startingScore: StartingScore = .five01, players: [Player]) {
        self.id = id
        self.mode = mode
        self.startingScore = startingScore
        self.players = players
        self.turns = []
        self.createdAt = Date()
    }

    func remainingScore(for player: Player) -> Int {
        let playerTurns = turns.filter { $0.playerId == player.id }
        let scored = playerTurns.reduce(0) { $0 + $1.total }
        return max(0, startingScore.rawValue - scored)
    }
}


