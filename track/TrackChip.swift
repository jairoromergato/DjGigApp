
import SwiftUI

struct TrackChip: View {
    let title: String
    let artist: String
    var onRemove: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "music.note")
                .font(.caption)
            Text(title).lineLimit(1)
            if !artist.trimmed.isEmpty {
                Text("— \(artist)").lineLimit(1)
                    .foregroundStyle(.secondary)
            }
            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill").font(.caption)
            }
            .buttonStyle(.plain)
        }
        .font(.footnote.weight(.medium))
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            Capsule(style: .continuous)
                .fill(AppTheme.card)
                .overlay(Capsule().stroke(AppTheme.accent.opacity(0.35), lineWidth: 1))
                .shadow(radius: 2)
        )
        .foregroundStyle(AppTheme.textPrimary)
    }
}
//
//private extension String {
//    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
//}
