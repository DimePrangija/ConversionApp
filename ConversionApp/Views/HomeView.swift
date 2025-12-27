import SwiftUI
import SwiftData

struct HomeView: View {
    @StateObject var viewModel: ConversionViewModel
    @Environment(\.modelContext) private var context
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        inputSection
                        resultSection
                        actionButtons
                        infoSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Weight Converter")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { isInputFocused = false }
                }
            }
        }
        .tint(.buttonAccent)
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Enter weight")
                .font(.headline)
                .foregroundStyle(.white)

            HStack(spacing: 12) {
                TextField("0.0", text: $viewModel.inputText)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(Color.white.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .cornerRadius(12)
                    .foregroundStyle(.white)
                    .focused($isInputFocused)
                    .accessibilityLabel("Weight input")

                Picker("Direction", selection: $viewModel.direction) {
                    ForEach(ConversionDirection.allCases) { direction in
                        Text(direction.label).tag(direction)
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.12))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .foregroundStyle(.white)
                .accessibilityLabel("Conversion direction")
            }

            Button {
                viewModel.swapUnits()
            } label: {
                Label("Swap units", systemImage: "arrow.up.arrow.down")
            }
            .buttonStyle(GradientButtonStyle())
            .accessibilityLabel("Swap units between pounds and kilograms")
        }
        .appCardStyle()
    }

    private var resultSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Result")
                .font(.headline)
                .foregroundStyle(.white)
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(viewModel.resultText)
                    .font(.system(size: 42, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .foregroundStyle(.white)
                Text(viewModel.direction.to.shortLabel)
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.7))
            }
            Text(viewModel.direction.accessibleLabel)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
        .appCardStyle()
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.copyResult()
            } label: {
                Label("Copy result", systemImage: "doc.on.doc")
            }
            .buttonStyle(GradientButtonStyle())
            .disabled(viewModel.lastResult == nil)
            .accessibilityLabel("Copy conversion result to clipboard")

            Button {
                Task { await viewModel.saveToHistory(context: context) }
            } label: {
                Label("Save to history", systemImage: "square.and.arrow.down")
            }
            .buttonStyle(GradientButtonStyle())
            .disabled(viewModel.lastResult == nil)
            .accessibilityLabel("Save this conversion to history")
        }
        .appCardStyle()
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Tips")
                .font(.headline)
                .foregroundStyle(.white)
            Text("• Live conversion updates as you type with rounding to your preferred decimal places.")
                .foregroundStyle(.white)
            Text("• Negative numbers are supported and labeled in the result.")
                .foregroundStyle(.white)
            Text("• Works fully offline; history syncs when the optional server is reachable.")
                .foregroundStyle(.white.opacity(0.7))
        }
        .font(.footnote)
        .appCardStyle()
    }
}

#Preview {
    HomeView(viewModel: ConversionViewModel(userSettings: UserSettings(), apiClient: APIClient()))
        .modelContainer(PersistenceController.makePreview().container)
}
