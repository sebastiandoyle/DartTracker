import Foundation

final class PersistenceService {
    private let recentKey = "recent_games"

    func loadRecentGames() -> [Game] {
        guard let data = UserDefaults.standard.data(forKey: recentKey) else { return [] }
        do {
            return try JSONDecoder().decode([Game].self, from: data)
        } catch {
            return []
        }
    }

    func saveRecentGames(_ games: [Game]) {
        do {
            let data = try JSONEncoder().encode(games)
            UserDefaults.standard.set(data, forKey: recentKey)
        } catch {
            // Ignore write errors for now
        }
    }
}


