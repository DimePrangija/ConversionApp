import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.apiClient) private var apiClient
    @Environment(\.userSettings) private var userSettings
    @Environment(\.hapticsService) private var haptics

    var body: some View {
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
        .accentColor(.primary)
    }
}

#Preview {
    ContentView()
        .modelContainer(PersistenceController.makePreview().container)
}
