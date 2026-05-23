import SwiftUI

struct NightPhotoTile: View {
    let imageReference: String
    var walkTitle: String?
    var subtitle: String?
    var height: CGFloat = 160
    var showOverlay: Bool = true

    private var isURL: Bool {
        imageReference.lowercased().hasPrefix("http")
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            imageContent
                .frame(height: height)
                .frame(maxWidth: .infinity)
                .clipped()

            if showOverlay {
                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.75)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 4) {
                    if let walkTitle {
                        Text(walkTitle)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                    }
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(1)
                    }
                }
                .padding(12)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: SkylineLayout.cardRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: SkylineLayout.cardRadius, style: .continuous)
                .strokeBorder(Color.skylineBorderGradient, lineWidth: 1)
        }
        .compositingGroup()
        .shadow(color: Color.black.opacity(0.35), radius: SkylineElevation.card.radius, y: SkylineElevation.card.y)
    }

    @ViewBuilder
    private var imageContent: some View {
        if isURL, let url = URL(string: imageReference) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    placeholderScene
                case .empty:
                    ZStack {
                        placeholderScene
                        ProgressView()
                            .tint(.skylineAccent)
                    }
                @unknown default:
                    placeholderScene
                }
            }
        } else {
            ZStack {
                placeholderScene
                VStack(spacing: 8) {
                    Image(systemName: "photo.artframe")
                        .font(.title)
                        .foregroundColor(.white.opacity(0.9))
                    Text(imageReference)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 8)
                }
            }
        }
    }

    private var placeholderScene: some View {
        NightSceneIllustration(variant: .fromSeed(imageReference.hashValue))
    }
}

struct NightSceneIllustration: View {
    enum Variant: CaseIterable {
        case waterfront
        case downtown
        case park
        case bridge

        static func fromSeed(_ seed: Int) -> Variant {
            allCases[abs(seed) % allCases.count]
        }

        var colors: [Color] {
            switch self {
            case .waterfront:
                return [Color(red: 0.05, green: 0.15, blue: 0.35), Color(red: 0.1, green: 0.35, blue: 0.55)]
            case .downtown:
                return [Color(red: 0.08, green: 0.1, blue: 0.25), Color(red: 0.15, green: 0.2, blue: 0.45)]
            case .park:
                return [Color(red: 0.04, green: 0.18, blue: 0.22), Color(red: 0.08, green: 0.32, blue: 0.38)]
            case .bridge:
                return [Color(red: 0.1, green: 0.12, blue: 0.3), Color(red: 0.2, green: 0.28, blue: 0.5)]
            }
        }

        var icon: String {
            switch self {
            case .waterfront: return "water.waves"
            case .downtown: return "building.2.fill"
            case .park: return "tree.fill"
            case .bridge: return "road.lanes"
            }
        }
    }

    let variant: Variant

    var body: some View {
        ZStack {
            LinearGradient(colors: variant.colors, startPoint: .topLeading, endPoint: .bottomTrailing)

            GeometryReader { geo in
                skylineSilhouette(width: geo.size.width, height: geo.size.height)
            }

            Circle()
                .fill(Color.white.opacity(0.35))
                .frame(width: 44, height: 44)
                .offset(x: 60, y: -50)
            Circle()
                .fill(Color.white.opacity(0.9))
                .frame(width: 28, height: 28)
                .offset(x: 60, y: -50)

            Image(systemName: variant.icon)
                .font(.system(size: 44))
                .foregroundColor(.white.opacity(0.15))
                .offset(x: 40, y: 20)
        }
    }

    private func skylineSilhouette(width: CGFloat, height: CGFloat) -> some View {
        HStack(alignment: .bottom, spacing: 4) {
            building(height: height * 0.35, width: 28)
            building(height: height * 0.55, width: 36)
            building(height: height * 0.42, width: 24)
            building(height: height * 0.68, width: 44)
            building(height: height * 0.48, width: 30)
            building(height: height * 0.58, width: 38)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, 8)
    }

    private func building(height: CGFloat, width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 3, style: .continuous)
            .fill(Color.black.opacity(0.45))
            .frame(width: width, height: height)
            .overlay(alignment: .top) {
                VStack(spacing: 5) {
                    ForEach(0..<4, id: \.self) { _ in
                        HStack(spacing: 4) {
                            Circle().fill(Color.skylineAccent.opacity(0.8)).frame(width: 3, height: 3)
                            Circle().fill(Color.skylineAccent.opacity(0.5)).frame(width: 3, height: 3)
                        }
                    }
                }
                .padding(.top, 8)
            }
    }
}

extension NightSceneIllustration.Variant {
    static func from(neighborhood: Neighborhood) -> Self {
        switch neighborhood {
        case .waterfront: return .waterfront
        case .park, .residential: return .park
        case .downtown, .business, .oldTown: return .downtown
        case .other: return .bridge
        }
    }

    static func from(mood: WalkMood) -> Self {
        switch mood {
        case .peaceful, .romantic: return .waterfront
        case .energetic, .adventurous: return .downtown
        case .reflective: return .park
        }
    }
}
