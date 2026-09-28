//
//  CreateMemoryView.swift
//  MemoryAtlas
//
//  Created by Chandresh Ahir on 9/28/26.
//

import Foundation
import SwiftUI

struct CreateMemoryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CreateMemoryViewModel
    private let onSaved: () async -> Void

    init(
        viewModel: CreateMemoryViewModel,
        onSaved: @escaping () async -> Void = {}
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onSaved = onSaved
    }

    private var isSaving: Bool {
        if case .saving = viewModel.state {
            return true
        }

        return false
    }

    private var errorMessage: String? {
        if case let .failed(message) = viewModel.state {
            return message
        }

        return nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $viewModel.title)
                        .accessibilityIdentifier("createMemory.titleField")

                    DatePicker(
                        "Date",
                        selection: $viewModel.memoryDate,
                        displayedComponents: .date
                    )
                    .accessibilityIdentifier("createMemory.datePicker")

                    TextEditor(text: $viewModel.note)
                        .frame(minHeight: 120)
                        .accessibilityIdentifier("createMemory.noteEditor")
                }
                .disabled(isSaving)

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .accessibilityIdentifier("createMemory.error")
                }

                Button {
                    save()
                } label: {
                    if isSaving {
                        ProgressView()
                            .accessibilityIdentifier("createMemory.loading")
                    } else {
                        Text("Save Memory")
                    }
                }
                .disabled(!viewModel.canSave)
                .accessibilityIdentifier("createMemory.saveButton")
            }
            .navigationTitle("New Memory")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSaving)
                    .accessibilityIdentifier("createMemory.cancelButton")
                }
            }
        }
    }

    private func save() {
        Task {
            await viewModel.save()

            if case .saved = viewModel.state {
                await onSaved()
                dismiss()
            }
        }
    }
}


#if DEBUG

private struct CreateMemoryPreviewRepository: MemoryRepository {
    func fetchMemories() async throws -> [Memory] {
        []
    }

    func save(_ memory: Memory) async throws {
        // Preview does not persist anything.
    }
}

#Preview("New Memory") {
    CreateMemoryView(
        viewModel: CreateMemoryViewModel(
            memoryRepository: CreateMemoryPreviewRepository()
        )
    )
}

#endif
