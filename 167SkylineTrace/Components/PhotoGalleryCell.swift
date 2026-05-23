import SwiftUI

struct PhotoGalleryCell: View {
    let photo: GalleryPhotoItem

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.skylineAccent.opacity(0.35),
                                Color.skylineAccent.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)

                Image(systemName: "photo.on.rectangle.angled")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(photo.imageName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.skylineText)
                    .lineLimit(2)

                HStack(spacing: 6) {
                    Image(systemName: "figure.walk")
                        .font(.caption2)
                    Text(photo.walkTitle)
                        .font(.caption)
                        .lineLimit(1)
                }
                .foregroundColor(.skylineAccent)

                Text(photo.date, style: .date)
                    .font(.caption2)
                    .foregroundColor(.skylineMuted)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundColor(.skylineAccent.opacity(0.5))
        }
        .skylineListCard()
    }
}
