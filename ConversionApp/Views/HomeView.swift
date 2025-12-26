import SwiftUI
import SwiftData

struct HomeView: View {
    @StateObject var viewModel: ConversionViewModel
    @Environment(\.modelContext) private var context
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    inputSection
                    resultSection
                    actionButtons
                    infoSection
                }
                .padding()
            }
            .navigationTitle("Weight Converter")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { isInputFocused = false }
                }
            }
        }
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Enter weight")
                .font(.headline)
            HStack {
                TextField("0.0", text: $viewModel.inputText)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .focused($isInputFocused)
                    .accessibilityLabel("Weight input")

                Picker("Direction", selection: $viewModel.direction) {
                    ForEach(ConversionDirection.allCases) { direction in
                        Text(direction.label).tag(direction)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityLabel("Conversion direction")
            }

            Button {
                viewModel.swapUnits()
            } label: {
                Label("Swap units", systemImage: "arrow.up.arrow.down")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Swap units between pounds and kilograms")
        }
    }

    private var resultSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Result")
                .font(.headline)
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(viewModel.resultText)
                    .font(.system(size: 42, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(viewModel.direction.to.shortLabel)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            Text(viewModel.direction.accessibleLabel)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.copyResult()
            } label: {
                Label("Copy result", systemImage: "doc.on.doc")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.lastResult == nil)
            .accessibilityLabel("Copy conversion result to clipboard")

            Button {
                Task { await viewModel.saveToHistory(context: context) }
            } label: {
                Label("Save to history", systemImage: "square.and.arrow.down")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.lastResult == nil)
            .accessibilityLabel("Save this conversion to history")
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Tips")
                .font(.headline)
            Text("• Live conversion updates as you type with rounding to your preferred decimal places.")
            Text("• Negative numbers are supported and labeled in the result.")
            Text("• Works fully offline; history syncs when the optional server is reachable.")
                .foregroundStyle(.secondary)
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
    }
}

#Preview {
    HomeView(viewModel: ConversionViewModel(userSettings: UserSettings(), apiClient: APIClient()))
        .modelContainer(PersistenceController.makePreview().container)
}
