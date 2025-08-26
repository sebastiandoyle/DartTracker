import Foundation

struct ProbabilityProfile {
    var pTripleExact: Double
    var pDoubleExact: Double
    var pSingleExact: Double
    var pBullDoubleExact: Double   // 50 (inner bull)
    var pBullSingleExact: Double   // 25 (outer bull)

    static let `default` = ProbabilityProfile(
        pTripleExact: 0.35,
        pDoubleExact: 0.45,
        pSingleExact: 0.80,
        pBullDoubleExact: 0.20,
        pBullSingleExact: 0.50
    )
}

struct CheckoutRoute: Identifiable, Equatable {
    let id = UUID()
    let tokens: [String]   // e.g., ["T20", "S20", "D20"]
    let total: Int
    let probability: Double
}

/// Provides suggested checkout routes for remaining scores, prioritizing common pro routes.
final class CheckoutService {
    private let routes: [Int: [String]] = [
        170: ["T20, T20, D25"],
        167: ["T20, T19, D25"],
        164: ["T20, T18, D25"],
        161: ["T20, T17, D25"],
        160: ["T20, T20, D20"],
        158: ["T20, T20, D19"],
        157: ["T20, T19, D20"],
        156: ["T20, T20, D18"],
        155: ["T20, T19, D19"],
        154: ["T20, T18, D20"],
        153: ["T20, T19, D18"],
        152: ["T20, T20, D16"],
        151: ["T20, T17, D20"],
        150: ["T20, T18, D18"],
        149: ["T20, T19, D16"],
        148: ["T20, T20, D14"],
        147: ["T20, T17, D18"],
        146: ["T20, T18, D16"],
        145: ["T20, T15, D20"],
        144: ["T20, T20, D12"],
        141: ["T20, T19, D12"],
        140: ["T20, T20, D10"],
        136: ["T20, T20, D8"],
        132: ["T20, T12, D20"],
        131: ["T20, T13, D16"],
        130: ["T20, T18, D8"],
        129: ["T19, T16, D12"],
        128: ["T18, T14, D16"],
        127: ["T20, T17, D8"],
        126: ["T19, T19, D6"],
        124: ["T20, T16, D8"],
        122: ["T18, T18, D7"],
        121: ["T20, T11, D14"],
        120: ["T20, S20, D20"],
        118: ["T20, S18, D20"],
        117: ["T20, S17, D20"],
        116: ["T20, S16, D20"],
        115: ["T20, S15, D20"],
        114: ["T20, S14, D20"],
        113: ["T20, S13, D20"],
        112: ["T20, S12, D20"],
        111: ["T20, S11, D20"],
        110: ["T20, S10, D20"],
        109: ["T20, 9, D20"],
        108: ["T20, 8, D20"],
        107: ["T19, 10, D20"],
        106: ["T20, 6, D20"],
        105: ["T20, 13, D16"],
        104: ["T18, 18, D16"],
        103: ["T20, 3, D20"],
        102: ["T20, 10, D16"],
        101: ["T17, 10, D20"],
        100: ["T20, D20", "20, D20, D20"],
         99: ["T19, 10, D16"],
         98: ["T20, D19", "T19, 9, D16"],
         97: ["T19, D20"],
         96: ["T20, D18"],
         95: ["T19, D19"],
         94: ["T18, D20"],
         93: ["T19, D18"],
         92: ["T20, D16", "T12, D28"],
         91: ["T17, D20", "T19, D17"],
         90: ["T18, D18", "BULL, D20"],
         89: ["T19, D16"],
         88: ["T16, D20", "T20, D14"],
         87: ["T17, D18"],
         86: ["T18, D16"],
         85: ["T15, D20", "T19, D14"],
         84: ["T20, D12"],
         83: ["T17, D16"],
         82: ["BULL, D16", "T14, D20"],
         81: ["T15, D18"],
         80: ["T20, D10", "D20, D20"],
         79: ["T19, D11"],
         78: ["T18, D12"],
         77: ["T19, D10"],
         76: ["T20, D8", "T16, D14"],
         75: ["T17, D12"],
         74: ["T14, D16"],
         73: ["T19, D8"],
         72: ["T16, D12", "T20, D6"],
         71: ["T13, D16"],
         70: ["T18, D8", "S20, D25, D25"],
         69: ["T19, D6", "T15, D12"],
         68: ["T20, D4", "T16, D10"],
         67: ["T17, D8"],
         66: ["T10, D18", "T14, D12"],
         65: ["T19, D4", "25, D20, D10"],
         64: ["T16, D8", "D16, D16"],
         63: ["T13, D12", "T17, D6"],
         62: ["T10, D16", "T14, D10"],
         61: ["T15, D8", "25, D18"],
         60: ["S20, D20"]
    ]

    func suggestCheckout(for remaining: Int) -> [String] {
        if remaining < 2 || remaining > 170 { return [] }
        // Prefer curated first, else fall back to generated top route(s)
        if let curated = routes[remaining], !curated.isEmpty { return curated }
        let generated = suggestCheckouts(for: remaining, limit: 3)
        return generated.map { $0.tokens.joined(separator: ", ") }
    }

    func suggestCheckouts(for remaining: Int, limit: Int = 10, profile: ProbabilityProfile = .default) -> [CheckoutRoute] {
        if remaining < 2 || remaining > 170 { return [] }
        var unique = Set<String>()
        var results: [CheckoutRoute] = []

        // Token spaces
        let singles: [String] = (1...20).map { "S\($0)" } + ["25"]
        let triples: [String] = (1...20).map { "T\($0)" }
        let doubles: [String] = (1...20).map { "D\($0)" } + ["D25"]

        func score(of token: String) -> Int {
            if token == "25" { return 25 }
            if token == "D25" { return 50 }
            let num = Int(token.dropFirst()) ?? 0
            if token.hasPrefix("S") { return num }
            if token.hasPrefix("D") { return num * 2 }
            if token.hasPrefix("T") { return num * 3 }
            return 0
        }

        func normalizeToken(_ raw: String) -> String {
            let t = raw.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            if t == "BULL" { return "D25" }
            if t == "S25" { return "25" }
            if let n = Int(t) { return "S\(n)" }
            return t
        }

        // Approximate area fractions based on standard dartboard proportions used in UI
        let rBullInner: Double = 0.06
        let rBullOuter: Double = 0.12
        let rTripleInner: Double = 0.53
        let rTripleOuter: Double = 0.60
        let rDoubleInner: Double = 0.90
        let rDoubleOuter: Double = 1.00
        let totalArea: Double = .pi * rDoubleOuter * rDoubleOuter

        func areaFraction(of tokenRaw: String) -> Double {
            let token = normalizeToken(tokenRaw)
            // Bulls (no wedge factor)
            if token == "D25" {
                let a = .pi * rBullInner * rBullInner
                return a / totalArea
            }
            if token == "25" {
                let a = .pi * (rBullOuter * rBullOuter - rBullInner * rBullInner)
                return a / totalArea
            }
            // Segment wedges -> divide ring area by 20
            let wedgeDiv: Double = 20.0
            if token.hasPrefix("D") {
                let a = .pi * (rDoubleOuter * rDoubleOuter - rDoubleInner * rDoubleInner) / wedgeDiv
                return a / totalArea
            }
            if token.hasPrefix("T") {
                let a = .pi * (rTripleOuter * rTripleOuter - rTripleInner * rTripleInner) / wedgeDiv
                return a / totalArea
            }
            if token.hasPrefix("S") {
                // Singles exist in two rings (inner single and outer single) for a segment
                let innerSingle = .pi * (rTripleInner * rTripleInner - rBullOuter * rBullOuter) / wedgeDiv
                let outerSingle = .pi * (rDoubleInner * rDoubleInner - rTripleOuter * rTripleOuter) / wedgeDiv
                return (innerSingle + outerSingle) / totalArea
            }
            return 0
        }

        func push(_ tokens: [String]) {
            let key = tokens.joined(separator: ",")
            guard !unique.contains(key) else { return }
            unique.insert(key)
            let total = tokens.reduce(0) { $0 + score(of: $1) }
            guard total == remaining else { return }
            // Must finish on a double
            guard let last = tokens.last, last.hasPrefix("D") || last == "D25" else { return }
            let p = tokens.reduce(1.0) { $0 * max(1e-12, areaFraction(of: $1)) }
            results.append(CheckoutRoute(tokens: tokens, total: total, probability: p))
        }

        // One-dart
        for d in doubles {
            if score(of: d) == remaining { push([d]) }
        }
        // Two-dart
        let aTokens = singles + triples
        for a in aTokens {
            for d in doubles {
                if score(of: a) + score(of: d) == remaining { push([a, d]) }
            }
        }
        // Three-dart (prune by plausible max)
        // Early prune: skip paths where partial sum already exceeds remaining
        for a in aTokens {
            let sa = score(of: a)
            if sa >= remaining { continue }
            for b in aTokens {
                let sab = sa + score(of: b)
                if sab >= remaining { continue }
                for d in doubles {
                    if sab + score(of: d) == remaining { push([a, b, d]) }
                }
            }
        }

        // Merge curated routes (if any), ensuring they appear with probability based on profile
        if let curated = routes[remaining] {
            for routeStr in curated {
                let tokens = routeStr.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                let p = tokens.reduce(1.0) { acc, t in
                    let token = String(t)
                    return acc * max(1e-12, areaFraction(of: token))
                }
                let key = tokens.joined(separator: ",")
                if !unique.contains(key) {
                    unique.insert(key)
                    results.append(CheckoutRoute(tokens: tokens.map { String($0) }, total: remaining, probability: p))
                }
            }
        }

        // Normalize probabilities to sum to 1.0 (relative likelihoods)
        let sumP = results.reduce(0.0) { $0 + $1.probability }
        if sumP > 0 {
            results = results.map { CheckoutRoute(tokens: $0.tokens, total: $0.total, probability: $0.probability / sumP) }
        }

        // Sort by probability desc, then by token count asc (prefer shorter), then lexicographically
        results.sort { lhs, rhs in
            if lhs.probability != rhs.probability { return lhs.probability > rhs.probability }
            if lhs.tokens.count != rhs.tokens.count { return lhs.tokens.count < rhs.tokens.count }
            return lhs.tokens.joined(separator: ",") < rhs.tokens.joined(separator: ",")
        }

        if limit > 0 { return Array(results.prefix(limit)) }
        return results
    }
}


