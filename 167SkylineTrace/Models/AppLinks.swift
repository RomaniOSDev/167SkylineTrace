import Foundation

enum AppLinks: String {
    case privacyPolicy = "https://www.termsfeed.com/live/3a33d4bc-b1ca-4e7d-bcf4-e183e14da506"
    case termsOfUse = "https://www.termsfeed.com/live/df099c79-eb31-46d7-bc77-e6de54c94aa1"

    var url: URL? {
        URL(string: rawValue)
    }
}
