import Foundation

enum NightQuoteProvider {
    private static let quotes = [
        "The city at night is a completely different universe. Light, shadows, silence...",
        "Streetlamps draw paths only night walkers can see.",
        "Every corner holds a story when the crowds are gone.",
        "The river mirrors the skyline like a second city below.",
        "Footsteps echo louder when the day has fallen asleep.",
        "Neon signs hum softly above empty sidewalks.",
        "Night air carries secrets between old buildings.",
        "A single window lit late feels like an invitation to wander.",
        "Bridges glow as if they were built only for midnight crossings.",
        "The best views appear when the city thinks no one is watching."
    ]

    static func randomQuote() -> String {
        quotes.randomElement() ?? quotes[0]
    }
}
