import SwiftUI

struct DurationWheelOverlay: View {
    @Binding var minutes: Int
    var onCancel: () -> Void
    var onDone: () -> Void

    @State private var temp: Int = 0

    var body: some View {
        // Fondo semitransparente que cierra al tocar fuera
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { onCancel() }

            // “Bottom sheet” con la ruleta
            VStack(spacing: 0) {
                // Gripper
                Capsule()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)
                    .padding(.bottom, 6)

                // Título + valor actual
                Text("Selecciona duración")
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)
                    .padding(.top, 4)

                Text(durationString(temp))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary)
                    .padding(.bottom, 8)

                // Ruleta (DatePicker en wheel)
                DurationWheelPicker(minutes: $temp)
                    .frame(height: 216)
                    .background(AppTheme.card)

                // Botones
                HStack(spacing: 12) {
                    Button("Cancelar") { onCancel() }
                        .foregroundStyle(AppTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(AppTheme.card)
                        )

                    Button("Listo") {
                        minutes = temp
                        onDone()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(AppTheme.card.opacity(0.8))
            }
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AppTheme.card)
                    .ignoresSafeArea(edges: .bottom)
            )
            .padding(.horizontal, 8)
        }
        .onAppear { temp = minutes } // trabajamos sobre copia temporal
    }
}
