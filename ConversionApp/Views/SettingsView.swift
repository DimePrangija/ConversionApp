import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                Form {
                    Section("Defaults") {
                        Picker("Default direction", selection: $viewModel.defaultDirection) {
                            ForEach(ConversionDirection.allCases) { direction in
                                Text(direction.label).tag(direction)
                            }
                        }

                        Stepper(value: $viewModel.decimalPlaces, in: 0...4) {
                            HStack {
                                Text("Decimal places")
                                Spacer()
                                Text("\(viewModel.decimalPlaces)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .listRowBackground(Color.cardBackground)

                    Section("Feedback") {
                        Toggle("Haptics", isOn: $viewModel.hapticsEnabled)
                    }
                    .listRowBackground(Color.cardBackground)

                    Section {
                        Button {
                            viewModel.save()
                        } label: {
                            Label("Save Settings", systemImage: "checkmark.circle")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .buttonStyle(GradientButtonStyle())
                    }
                    .listRowBackground(Color.cardBackground)
                }
                .scrollContentBackground(.hidden)
                .background(Color.appBackground)
            }
            .navigationTitle("Settings")
        }
        .tint(.buttonAccent)
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel(userSettings: UserSettings()))
}
