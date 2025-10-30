import SwiftUI
struct CenteredDurationModal: View {
    @Binding var minutes: Int
    var onCancel: () -> Void
    var onDone: () -> Void

    @State private var temp: Int = 0

    var body: some View {
        ZStack {
            // Fondo atenuado: tap fuera cierra
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { onCancel() }

            // Tarjeta centrada
            VStack(spacing: 12) {
                Text("Duración")
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)
                    .padding(.top, 8)

                Text(localDurationString(temp))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary)

                DurationWheelPicker(minutes: $temp)
                    .frame(height: 216)

                HStack(spacing: 12) {
                    Button("Cancelar", action: onCancel)
                        .foregroundStyle(AppTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(AppTheme.card.opacity(0.9))
                        )

                    Button("Listo") {
                        minutes = temp
                        onDone()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 10)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AppTheme.card)
                    .shadow(radius: 20)
            )
            .frame(maxWidth: 360)
            .transition(.scale(scale: 0.9).combined(with: .opacity))
        }
        .onAppear { temp = minutes }
    }

    private func localDurationString(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        switch (h, m) {
        case (0, _): return "\(m) min"
        case (_, 0): return "\(h) h"
        default:     return "\(h) h \(m) min"
        }
    }
}

