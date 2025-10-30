import SwiftUI

struct DurationPickerSheet: View {
    @Binding var minutes: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Altura típica de rueda
                DurationWheelPicker(minutes: $minutes)
                    .frame(height: 220)
                    .padding(.top, 8)

                // Lectura en grande
                Text(durationString(minutes))
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .padding(.top, 12)

                Spacer()
            }
            .background(AppTheme.bg.ignoresSafeArea())
            .navigationTitle("Duración")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(AppTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") { dismiss() }
                        .buttonStyle(PrimaryButtonStyle())
                }
            }
        }
    }
}
