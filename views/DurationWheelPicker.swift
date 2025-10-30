import SwiftUI

struct DurationWheelPicker: View {
    @Binding var minutes: Int
    @State private var tempDate: Date

    init(minutes: Binding<Int>) {
        _minutes = minutes
        let h = minutes.wrappedValue / 60
        let m = minutes.wrappedValue % 60
        let comps = DateComponents(hour: h, minute: m)
        _tempDate = State(
            initialValue: Calendar.current.date(from: comps)
            ?? Date(timeIntervalSince1970: 0)
        )
    }

    var body: some View {
        DatePicker("", selection: $tempDate, displayedComponents: .hourAndMinute)
            .datePickerStyle(.wheel)
            .labelsHidden()
            .modifier(UpdateMinutesFromDate(tempDate: $tempDate, minutes: $minutes))
    }
}

private struct UpdateMinutesFromDate: ViewModifier {
    @Binding var tempDate: Date
    @Binding var minutes: Int

    func body(content: Content) -> some View {
        if #available(iOS 17, *) {
            content.onChange(of: tempDate) { _, newValue in
                let c = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                minutes = (c.hour ?? 0) * 60 + (c.minute ?? 0)
            }
        } else {
            content.onChange(of: tempDate) { newValue in
                let c = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                minutes = (c.hour ?? 0) * 60 + (c.minute ?? 0)
            }
        }
    }
}
