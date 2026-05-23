import SwiftUI

/// Static background — rasterized once via drawingGroup for smooth scrolling.
struct SkylineBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.09, blue: 0.2),
                    Color.skylineBackground,
                    Color(red: 0.04, green: 0.06, blue: 0.14)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [Color.skylineAccent.opacity(0.2), Color.clear],
                center: UnitPoint(x: 0.85, y: 0.08),
                startRadius: 0,
                endRadius: 280
            )

            RadialGradient(
                colors: [Color.skylineAccent.opacity(0.14), Color.clear],
                center: UnitPoint(x: 0.1, y: 0.92),
                startRadius: 0,
                endRadius: 260
            )

            StarfieldCanvas()
                .opacity(0.55)
        }
        .drawingGroup(opaque: true, colorMode: .nonLinear)
        .ignoresSafeArea()
    }
}

/// Fixed star positions — drawn in one Canvas pass (no per-frame GeometryReader).
private struct StarfieldCanvas: View {
    private static let stars: [(CGFloat, CGFloat, CGFloat)] = {
        (0..<10).map { i in
            let fi = CGFloat(i)
            return (
                (fi * 73).truncatingRemainder(dividingBy: 100) / 100,
                (fi * 41).truncatingRemainder(dividingBy: 100) / 100 * 0.65,
                fi.truncatingRemainder(dividingBy: 3) == 0 ? 1.5 : 1.0
            )
        }
    }()

    var body: some View {
        Canvas { context, size in
            for star in Self.stars {
                let point = CGPoint(x: star.0 * size.width, y: star.1 * size.height)
                let rect = CGRect(
                    x: point.x - star.2 / 2,
                    y: point.y - star.2 / 2,
                    width: star.2,
                    height: star.2
                )
                context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.07)))
            }
        }
    }
}
