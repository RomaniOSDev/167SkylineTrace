import Foundation

extension SkylineTraceViewModel {
    var homeHeroSlides: [HomeHeroSlide] {
        var slides: [HomeHeroSlide] = []

        if let best = bestWalkThisMonth {
            if let firstImage = best.imageNames?.first {
                slides.append(HomeHeroSlide(
                    title: best.title,
                    subtitle: "Best walk this month • \(best.formattedDate)",
                    badge: "FEATURED",
                    visual: .photo(reference: firstImage, neighborhood: best.neighborhood)
                ))
            } else {
                slides.append(HomeHeroSlide(
                    title: best.title,
                    subtitle: String(format: "%.1f km • %@", best.distance, best.mood.displayName),
                    badge: "FEATURED",
                    visual: .scene(.from(neighborhood: best.neighborhood))
                ))
            }
        }

        for walk in sortedWalks.prefix(3) {
            guard slides.count < 5 else { break }
            if let image = walk.imageNames?.first {
                slides.append(HomeHeroSlide(
                    title: walk.title,
                    subtitle: walk.neighborhood.displayName,
                    badge: walk.isFavorite ? "FAVORITE" : nil,
                    visual: .photo(reference: image, neighborhood: walk.neighborhood)
                ))
            }
        }

        let scenes: [NightSceneIllustration.Variant] = [.waterfront, .downtown, .park, .bridge]
        for scene in scenes where slides.count < 6 {
            slides.append(HomeHeroSlide(
                title: "Explore the city at night",
                subtitle: "Log walks, photos and moods",
                badge: nil,
                visual: .scene(scene)
            ))
        }

        return slides
    }

    var homePhotoStrip: [GalleryPhotoItem] {
        Array(galleryPhotos.prefix(12))
    }

    var homeRecentWalks: [NightWalk] {
        Array(sortedWalks.prefix(4))
    }

    var primaryActiveGoal: WalkGoal? {
        goals.first { !$0.isCompleted } ?? goals.first
    }

    var monthWalksDeltaText: String {
        let delta = periodComparison.walksDelta
        return delta >= 0 ? "+\(delta) vs last month" : "\(delta) vs last month"
    }

    var monthDistanceDeltaText: String {
        let delta = periodComparison.distanceDelta
        return String(format: delta >= 0 ? "+%.1f km vs last month" : "%.1f km vs last month", delta)
    }
}
