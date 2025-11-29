import SwiftUI
import SwiftData

struct HomeView: View {
    @Query (sort: \Gig.date) private var gigs: [Gig]
    @State private var vm = HomeViewModel()
    private let router = HomeRouter()

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.bg.ignoresSafeArea()

                VStack(spacing: 0) {
                    VStack(spacing: 8) {
                        Label {
                            Text(HomeStrings.appTitle)
                                .font(.system(size: 34, weight: .bold))
                        } icon: {
                            Image(systemName: "headphones")
                        }
                        .foregroundStyle(AppTheme.accent)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 48)
                    .padding(.bottom, 16)

                    VStack(spacing: 16) {
                        ForEach(vm.actions) { action in
                            NavigationLink {
                                router.destination(for: action, gigs: gigs)
                            } label: {
                                HomeActionButton(
                                    title: action.title,
                                    systemIcon: action.systemIcon
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth: 520)
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity,
                           maxHeight: .infinity,
                           alignment: .center)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

