import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\.timestamp, order: .reverse)]) private var records: [ConversionRecord]
    @StateObject var viewModel: HistoryViewModel
    @State private var showingClearConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                if filteredRecords.isEmpty {
                    ContentUnavailableView("No history", systemImage: "clock", description: Text("Save a conversion to see it here."))
                } else {
                    ForEach(filteredRecords) { record in
                        HistoryRow(record: record)
                            .swipeActions {
                                Button(role: .destructive) {
                                    viewModel.delete(record, context: context)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .navigationTitle("History")
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .automatic))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Filter", selection: $viewModel.filterDirection) {
                            Text("All directions").tag(ConversionDirection?.none)
                            ForEach(ConversionDirection.allCases) { direction in
                                Text(direction.label).tag(Optional(direction))
                            }
                        }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear") { showingClearConfirmation = true }
                        .disabled(records.isEmpty)
                }
            }
            .confirmationDialog("Clear all history?", isPresented: $showingClearConfirmation, titleVisibility: .visible) {
                Button("Delete All", role: .destructive) {
                    Task { await viewModel.clearAll(context: context) }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This removes all saved conversions locally and remotely.")
            }
            .task {
                await viewModel.refreshSync(context: context)
            }
        }
    }

    private var filteredRecords: [ConversionRecord] {
        records.filter { viewModel.matchesFilter($0) }
    }
}

struct HistoryRow: View {
    let record: ConversionRecord
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("\(record.inputValue, specifier: "%.4f") \(record.fromUnit.shortLabel)")
                    .font(.subheadline)
                Image(systemName: "arrow.right")
                    .foregroundStyle(.secondary)
                Text("\(record.resultValue, specifier: "%.4f") \(record.toUnit.shortLabel)")
                    .font(.headline)
            }
            Text(formatter.string(from: record.timestamp))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(record.fromUnit.displayName) to \(record.toUnit.displayName) on \(formatter.string(from: record.timestamp))")
    }
}

#Preview {
    HistoryView(viewModel: HistoryViewModel(apiClient: APIClient()))
        .modelContainer(PersistenceController.makePreview().container)
}
