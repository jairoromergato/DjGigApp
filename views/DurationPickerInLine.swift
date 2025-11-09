import SwiftUI

struct DurationPickerInline: View {
    @Binding var minutes: Int

    // Rango razonable: 0–12 h
    private let hours = Array(0...12)
    private let mins  = Array(stride(from: 0, to: 60, by: 5)) // de 5 en 5

    private var currentH: Int { minutes / 60 }
    private var currentM: Int { minutes % 60 }

    var body: some View {
        HStack {
            // Hours
            Picker("Horas", selection: Binding(
                get: { currentH },
                set: { newH in minutes = newH * 60 + currentM }
            )) {
                ForEach(hours, id: \.self) { h in
                    Text("\(h) h").tag(h)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)

            // Minutes
            Picker("Minutos", selection: Binding(
                get: { currentM - (currentM % 5) }, // ajusta al paso
                set: { newM in minutes = currentH * 60 + newM }
            )) {
                ForEach(mins, id: \.self) { m in
                    Text("\(m) min").tag(m)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
        }
        .frame(height: 140)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Duración")
    }
}
