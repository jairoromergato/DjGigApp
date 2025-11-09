import SwiftUI

struct HomeActionButton: View {
    let title: String
    let systemIcon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemIcon).imageScale(.large)
            Text(title).font(.title3.weight(.semibold))
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
