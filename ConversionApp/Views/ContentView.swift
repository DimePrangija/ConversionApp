import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.apiClient) private var apiClient
    @Environment(\.userSettings) private var userSettings

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            TabView {
                HomeView(viewModel: ConversionViewModel(userSettings: userSettings, apiClient: apiClient))
                    .tabItem {
                        Label("Convert", systemImage: "scalemass")
                    }

                HistoryView(viewModel: HistoryViewModel(apiClient: apiClient))
                    .tabItem {
                        Label("History", systemImage: "clock.arrow.circlepath")
                    }

                SettingsView(viewModel: SettingsViewModel(userSettings: userSettings))
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
        }
        .tint(.buttonAccent)
    }
}

#Preview {
    ContentView()
        .modelContainer(PersistenceController.makePreview().container)
}
