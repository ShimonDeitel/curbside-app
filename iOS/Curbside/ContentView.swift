import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var editing: RefundVisit?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    ForEach(store.items) { item in
                        Button {
                            editing = item
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.center)
                                        .font(Theme.headlineFont)
                                        .foregroundStyle(.primary)
                                    Text(item.id.uuidString.prefix(8))
                                        .font(Theme.captionFont)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(item.refundAmount, format: .currency(code: "USD"))
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.accent)
                            }
                        }
                        .accessibilityIdentifier("row_\(item.center)")
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)

                if store.items.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "tray")
                            .font(.system(size: 40))
                            .foregroundStyle(Theme.accent)
                        Text("No entries yet")
                            .font(Theme.bodyFont)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Curbside")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                EntrySheet(mode: .add)
                    .environmentObject(store)
            }
            .sheet(item: $editing) { item in
                EntrySheet(mode: .edit(item))
                    .environmentObject(store)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(store)
                    .environmentObject(purchases)
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
                    .environmentObject(purchases)
            }
        }
        .tint(Theme.accent)
    }
}

enum EntryMode: Equatable {
    case add
    case edit(RefundVisit)
}

struct EntrySheet: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    let mode: EntryMode
    @State private var draft: RefundVisit

    init(mode: EntryMode) {
        self.mode = mode
        switch mode {
        case .add:
            _draft = State(initialValue: RefundVisit())
        case .edit(let item):
            _draft = State(initialValue: item)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Center", text: $draft.center)
                    .accessibilityIdentifier("field_center")

                TextField("Refund amount", value: $draft.refundAmount, format: .number)
                    .keyboardType(.decimalPad)
                    .accessibilityIdentifier("field_refundAmount")

                DatePicker("Visit date", selection: $draft.visitDate, displayedComponents: .date)
                    .accessibilityIdentifier("field_visitDate")

                TextField("Item count", value: $draft.itemCount, format: .number)
                    .keyboardType(.numberPad)
                    .accessibilityIdentifier("field_itemCount")

                TextField("Notes", text: $draft.notes)
                    .accessibilityIdentifier("field_notes")
            }
            .scrollDismissesKeyboard(.immediately)
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle(mode == .add ? "Add Entry" : "Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        switch mode {
                        case .add:
                            store.add(draft)
                        case .edit:
                            store.update(draft)
                        }
                        dismiss()
                    }
                    .accessibilityIdentifier("saveButton")
                }
            }
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
