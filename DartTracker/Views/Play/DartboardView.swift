import SwiftUI

struct DartHit: Identifiable, Equatable {
    let id = UUID()
    let value: Int
    let token: String
    let normalizedPoint: CGPoint
}

struct DartboardView: View {
    // Tokens to highlight, e.g. ["T20", "D20", "BULL", "25", "S20", "20"]
    var highlightTokens: Set<String> = []
    var lastHits: [DartHit] = []
    var onHit: (DartHit) -> Void

    private let segmentOrder: [Int] = [20, 1, 18, 4, 13, 6, 10, 15, 2, 17, 3, 19, 7, 16, 8, 11, 14, 9, 12, 5]

    // Normalized radii (0..1) based on standard board proportions
    private let rBullInner: CGFloat = 0.06
    private let rBullOuter: CGFloat = 0.12
    private let rTripleInner: CGFloat = 0.53
    private let rTripleOuter: CGFloat = 0.60
    private let rDoubleInner: CGFloat = 0.90
    private let rDoubleOuter: CGFloat = 1.00

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2.0, y: geo.size.height / 2.0)
            let radius = size / 2.0

            ZStack {
                boardBackground(center: center, radius: radius)
                segmentDividers(center: center, radius: radius)
                highlightOverlays(center: center, radius: radius)
                lastHitMarkers(center: center, radius: radius)
            }
            .contentShape(Circle())
            .gesture(DragGesture(minimumDistance: 0).onEnded { value in
                let local = value.location
                let dx = local.x - center.x
                let dy = local.y - center.y
                let dist = sqrt(dx*dx + dy*dy)
                let rNorm = dist / radius
                guard rNorm <= rDoubleOuter else { return }

                var theta = atan2(dy, dx) + .pi / 2.0
                if theta < 0 { theta += 2.0 * .pi }
                let sector = Int(floor(theta / (2.0 * .pi / 20.0))) % 20
                let number = segmentOrder[sector]

                let (value, token): (Int, String) = {
                    if rNorm <= rBullInner {
                        return (50, "D25")
                    } else if rNorm <= rBullOuter {
                        return (25, "25")
                    } else if rNorm >= rDoubleInner && rNorm <= rDoubleOuter {
                        return (number * 2, "D\(number)")
                    } else if rNorm >= rTripleInner && rNorm <= rTripleOuter {
                        return (number * 3, "T\(number)")
                    } else {
                        return (number, "S\(number)")
                    }
                }()

                let normalizedPoint = CGPoint(x: dx / radius, y: dy / radius)
                onHit(DartHit(value: value, token: token, normalizedPoint: normalizedPoint))
            })
        }
        .aspectRatio(1, contentMode: .fit)
    }

    // MARK: - Drawing helpers

    @ViewBuilder
    private func boardBackground(center: CGPoint, radius: CGFloat) -> some View {
        // Base
        Circle()
            .fill(Color(.systemBackground))
            .overlay(Circle().stroke(Color.secondary.opacity(0.4), lineWidth: radius * 0.02))

        // Singles and rings
        ringWedges(center: center, radius: radius, inner: rDoubleInner, outer: rDoubleOuter, fillEvenOdd: (Color(.systemGray6), Color(.systemGray5)))
        ringWedges(center: center, radius: radius, inner: rTripleOuter, outer: rDoubleInner, fillEvenOdd: (Color(.systemGray6), Color(.systemGray5)))
        ringWedges(center: center, radius: radius, inner: rBullOuter, outer: rTripleInner, fillEvenOdd: (Color(.systemGray6), Color(.systemGray5)))
        ringWedges(center: center, radius: radius, inner: rTripleInner, outer: rTripleOuter, fillEvenOdd: (Color.red, Color.green))
        ringWedges(center: center, radius: radius, inner: rDoubleInner, outer: rDoubleOuter, fillEvenOdd: (Color.red, Color.green))

        // Bulls
        Circle()
            .fill(Color.green)
            .frame(width: radius * rBullOuter * 2.0, height: radius * rBullOuter * 2.0)
        Circle()
            .fill(Color.red)
            .frame(width: radius * rBullInner * 2.0, height: radius * rBullInner * 2.0)
    }

    @ViewBuilder
    private func ringWedges(center: CGPoint, radius: CGFloat, inner: CGFloat, outer: CGFloat, fillEvenOdd: (Color, Color)) -> some View {
        let angleStep = 2.0 * .pi / 20.0
        ForEach(0..<20, id: \.self) { i in
            let start = -Double.pi / 2.0 + Double(i) * angleStep
            let end = start + angleStep
            Path { p in
                p.addArc(center: center, radius: radius * outer, startAngle: .radians(start), endAngle: .radians(end), clockwise: false)
                p.addArc(center: center, radius: radius * inner, startAngle: .radians(end), endAngle: .radians(start), clockwise: true)
                p.closeSubpath()
            }
            .fill(i % 2 == 0 ? fillEvenOdd.0 : fillEvenOdd.1)
        }
    }

    @ViewBuilder
    private func highlightOverlays(center: CGPoint, radius: CGFloat) -> some View {
        let angleStep = 2.0 * .pi / 20.0
        ForEach(0..<20, id: \.self) { i in
            let number = segmentOrder[i]
            let start = -Double.pi / 2.0 + Double(i) * angleStep
            let end = start + angleStep

            // Double highlight
            if highlightTokens.contains("D\(number)") {
                ringOverlay(center: center, radius: radius, inner: rDoubleInner, outer: rDoubleOuter, start: start, end: end)
            }
            // Triple highlight
            if highlightTokens.contains("T\(number)") {
                ringOverlay(center: center, radius: radius, inner: rTripleInner, outer: rTripleOuter, start: start, end: end)
            }
            // Single highlight (both inner single zones)
            if highlightTokens.contains("S\(number)") || highlightTokens.contains("\(number)") {
                ringOverlay(center: center, radius: radius, inner: rTripleOuter, outer: rDoubleInner, start: start, end: end)
                ringOverlay(center: center, radius: radius, inner: rBullOuter, outer: rTripleInner, start: start, end: end)
            }
        }

        // Bulls
        if highlightTokens.contains("BULL") || highlightTokens.contains("D25") {
            Circle()
                .strokeBorder(Color.accentColor, lineWidth: 4)
                .background(Circle().fill(Color.accentColor.opacity(0.25)))
                .frame(width: radius * rBullInner * 2.0, height: radius * rBullInner * 2.0)
        }
        if highlightTokens.contains("25") || highlightTokens.contains("S25") {
            Circle()
                .strokeBorder(Color.accentColor, lineWidth: 4)
                .background(Circle().fill(Color.accentColor.opacity(0.15)))
                .frame(width: radius * rBullOuter * 2.0, height: radius * rBullOuter * 2.0)
        }
    }

    @ViewBuilder
    private func ringOverlay(center: CGPoint, radius: CGFloat, inner: CGFloat, outer: CGFloat, start: Double, end: Double) -> some View {
        Path { p in
            p.addArc(center: center, radius: radius * outer, startAngle: .radians(start), endAngle: .radians(end), clockwise: false)
            p.addArc(center: center, radius: radius * inner, startAngle: .radians(end), endAngle: .radians(start), clockwise: true)
            p.closeSubpath()
        }
        .fill(Color.accentColor.opacity(0.25))
        .overlay(
            Path { p in
                p.addArc(center: center, radius: radius * outer, startAngle: .radians(start), endAngle: .radians(end), clockwise: false)
                p.addArc(center: center, radius: radius * inner, startAngle: .radians(end), endAngle: .radians(start), clockwise: true)
                p.closeSubpath()
            }
            .stroke(Color.accentColor, lineWidth: 2)
        )
    }

    @ViewBuilder
    private func segmentDividers(center: CGPoint, radius: CGFloat) -> some View {
        ForEach(0..<20, id: \.self) { i in
            let angleStep = 2.0 * .pi / 20.0
            let startAngle = -Double.pi / 2.0 + Double(i) * angleStep
            Path { p in
                p.move(to: center)
                p.addLine(to: CGPoint(
                    x: center.x + cos(startAngle) * radius,
                    y: center.y + sin(startAngle) * radius
                ))
            }
            .stroke(Color.black.opacity(0.08), lineWidth: 1)
        }
    }

    @ViewBuilder
    private func lastHitMarkers(center: CGPoint, radius: CGFloat) -> some View {
        ForEach(lastHits) { hit in
            let pt = CGPoint(
                x: center.x + hit.normalizedPoint.x * radius,
                y: center.y + hit.normalizedPoint.y * radius
            )
            Circle()
                .strokeBorder(Color.accentColor, lineWidth: 3)
                .background(Circle().fill(Color.accentColor.opacity(0.2)))
                .frame(width: 16, height: 16)
                .position(pt)
        }
    }
}


