import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    var body: some View {
        SkylineScreenScaffold {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: SkylineLayout.sectionSpacing) {
                    SkylineSectionHeader(
                        title: "Support",
                        subtitle: "Feedback and legal information"
                    )

                    VStack(spacing: 12) {
                        SettingsRow(
                            title: "Rate us",
                            subtitle: "Enjoying the app? Leave a review",
                            icon: "star.fill"
                        ) {
                            rateApp()
                        }

                        SettingsRow(
                            title: "Privacy",
                            subtitle: "How we handle your data",
                            icon: "hand.raised.fill"
                        ) {
                            openPrivacyPolicy()
                        }

                        SettingsRow(
                            title: "Terms",
                            subtitle: "Terms of use",
                            icon: "doc.text.fill"
                        ) {
                            openTerms()
                        }
                    }
                }
                .skylineContentWidth()
                .skylineScreenPadding()
                .padding(.bottom, 28)
            }
        }
        .skylineScreen(title: "Settings")
    }

    private func openPrivacyPolicy() {
        if let url = AppLinks.privacyPolicy.url {
            UIApplication.shared.open(url)
        }
    }

    private func openTerms() {
        if let url = AppLinks.termsOfUse.url {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

private struct SettingsRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                SkylineIconBadge(icon: icon, size: 40, filled: false)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body.weight(.semibold))
                        .foregroundColor(.skylineText)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.skylineMuted)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.skylineMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .skylineListCard()
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
