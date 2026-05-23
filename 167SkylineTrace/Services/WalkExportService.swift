import Foundation
import UIKit

enum WalkExportService {
    static func makeTextReport(
        walks: [NightWalk],
        routes: [WalkRoute],
        goals: [WalkGoal],
        achievements: [AchievementRecord],
        comparison: PeriodComparison,
        bestWalk: NightWalk?
    ) -> String {
        var lines: [String] = []
        lines.append("NIGHT WALKS REPORT")
        lines.append("Generated: \(formattedDate(Date()))")
        lines.append("")
        lines.append("SUMMARY")
        lines.append("Total walks: \(walks.count)")
        lines.append(String(format: "Total distance: %.1f km", walks.reduce(0) { $0 + $1.distance }))
        lines.append("Total hours: \(walks.reduce(0) { $0 + $1.duration } / 60)")
        lines.append("")
        lines.append("THIS MONTH VS LAST")
        lines.append("Walks: \(comparison.current.walks) (\(signed(comparison.walksDelta)))")
        lines.append(String(format: "Distance: %.1f km (%@)", comparison.current.distance, signedDouble(comparison.distanceDelta)))
        lines.append("Hours: \(comparison.current.hours) (\(signed(comparison.hoursDelta)))")
        lines.append("")

        if let bestWalk {
            lines.append("BEST WALK THIS MONTH")
            lines.append("\(bestWalk.title) — \(bestWalk.formattedDate)")
            lines.append(String(format: "%.1f km • %@", bestWalk.distance, bestWalk.formattedDuration))
            lines.append("")
        }

        if !achievements.isEmpty {
            lines.append("ACHIEVEMENTS")
            for record in achievements.sorted(by: { $0.unlockedAt > $1.unlockedAt }) {
                lines.append("• \(record.type.title) — \(formattedDate(record.unlockedAt))")
            }
            lines.append("")
        }

        lines.append("RECENT WALKS")
        for walk in walks.sorted(by: { $0.date > $1.date }).prefix(20) {
            lines.append("— \(walk.title) (\(formattedDate(walk.date)))")
            lines.append("  \(walk.neighborhood.displayName), \(walk.mood.displayName)")
            lines.append(String(format: "  %.1f km, %@", walk.distance, walk.formattedDuration))
        }

        lines.append("")
        lines.append("ROUTES: \(routes.count) | GOALS: \(goals.count)")
        return lines.joined(separator: "\n")
    }

    static func makePDFData(report: String) -> Data? {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        return renderer.pdfData { context in
            context.beginPage()
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.white
            ]
            let attributed = NSAttributedString(string: report, attributes: attributes)
            attributed.draw(in: CGRect(x: 40, y: 40, width: pageRect.width - 80, height: pageRect.height - 80))
        }
    }

    private static func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }

    private static func signed(_ value: Int) -> String {
        value >= 0 ? "+\(value)" : "\(value)"
    }

    private static func signedDouble(_ value: Double) -> String {
        String(format: value >= 0 ? "+%.1f km" : "%.1f km", value)
    }
}
