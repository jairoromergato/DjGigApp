import SwiftUI

struct SocialView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 18) {

                ForEach(SocialPlatform.allCases) { platform in

                    Button {
                        platform.open()
                    } label: {
                        HStack {
                            Image(platform.iconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                                .padding(.leading, 16)

                            Spacer()

                            Text(platform.title)
                                .foregroundStyle(platform.textColor)
                                .font(.headline)

                            Spacer()

                            Image(platform.iconName)
                                .opacity(0) 
                                .frame(width: 28, height: 28)
                                .padding(.trailing, 16)
                        }
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .background(platform.buttonColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 816)
                                .stroke(Color.white.opacity(0.25), lineWidth: 2)
                        )
                        .cornerRadius(816)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Redes sociales")
        }
    }
}

#Preview {
    SocialView()
}
