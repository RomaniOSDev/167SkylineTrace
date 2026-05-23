import SwiftUI

extension View {
    /// Card surface: gradient fill, shine, border, one composited shadow.
    func skylineCellCard(
        accent: Color = .skylineAccent,
        glow: Bool = false,
        elevation: SkylineElevation? = nil
    ) -> some View {
        let level = elevation ?? SkylineElevation.forCard(glow: glow)
        return self.skylineDepthSurface(
            cornerRadius: SkylineDepth.cornerRadius,
            accent: accent,
            elevation: level,
            glow: glow
        )
    }

    func skylineDepthSurface(
        cornerRadius: CGFloat = SkylineDepth.cornerRadius,
        accent: Color = .skylineAccent,
        elevation: SkylineElevation = .card,
        glow: Bool = false
    ) -> some View {
        padding(SkylineLayout.cardPadding)
            .background {
                SkylineCardBackground(
                    cornerRadius: cornerRadius,
                    accent: accent,
                    glow: glow
                )
            }
            .compositingGroup()
            .shadow(
                color: glow ? accent.opacity(0.22) : elevation.shadowColor,
                radius: elevation.radius,
                x: 0,
                y: elevation.y
            )
    }

    func skylineInsetPanel() -> some View {
        padding(14)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.skylineAccent.opacity(0.12),
                                Color.skylineAccent.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.skylineAccent.opacity(0.2), lineWidth: 1)
            }
            .compositingGroup()
            .shadow(color: Color.black.opacity(0.2), radius: 4, y: 2)
    }

    /// Lighter depth for rows inside scroll views.
    func skylineListCard(accent: Color = .skylineAccent, glow: Bool = false) -> some View {
        skylineCellCard(accent: accent, glow: glow, elevation: .list)
    }

    /// Horizontal row cell (image + text) without outer padding.
    func skylineListRowSurface(
        accent: Color = .skylineAccent,
        glow: Bool = false,
        cornerRadius: CGFloat = SkylineDepth.cornerRadius
    ) -> some View {
        background {
            SkylineCardBackground(cornerRadius: cornerRadius, accent: accent, glow: glow)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .compositingGroup()
        .shadow(
            color: glow ? accent.opacity(0.2) : SkylineElevation.list.shadowColor,
            radius: SkylineElevation.list.radius,
            y: SkylineElevation.list.y
        )
    }
}

/// Shared card background — no shadow (applied outside via compositingGroup).
struct SkylineCardBackground: View {
    let cornerRadius: CGFloat
    let accent: Color
    let glow: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.skylineCardGradient)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.skylineSurfaceShine)
                    .allowsHitTesting(false)
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: borderColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .allowsHitTesting(false)
            }
    }

    private var borderColors: [Color] {
        if glow {
            return [
                accent.opacity(0.65),
                accent.opacity(0.25),
                Color.white.opacity(0.08)
            ]
        }
        return [
            Color.white.opacity(0.16),
            accent.opacity(0.28),
            Color.white.opacity(0.04)
        ]
    }
}

enum SkylineLayout {
    static let horizontalPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 20
    static let screenPadding: CGFloat = 12
    static let cardPadding: CGFloat = 16
    static let cardRadius: CGFloat = 18
}

extension View {
    func skylineScreen(title: String) -> some View {
        navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }

    func skylineContentWidth() -> some View {
        frame(maxWidth: .infinity, alignment: .leading)
    }

    func skylineScreenPadding() -> some View {
        padding(.horizontal, SkylineLayout.horizontalPadding)
            .padding(.vertical, SkylineLayout.screenPadding)
    }
}

enum SkylineListAppearance {
    static func configure() {
        UITableView.appearance().sectionHeaderTopPadding = 8

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(Color.skylineCardDeep)
        tabAppearance.shadowColor = UIColor.black.withAlphaComponent(0.35)
        tabAppearance.shadowImage = UIImage()

        UITabBar.appearance().standardAppearance = tabAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        }
    }
}
