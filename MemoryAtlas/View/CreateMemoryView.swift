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
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(AppTheme.memoryTitle)

                        TextField("Give this memory a title", text: $viewModel.title)
                            .accessibilityLabel("Title")
                            .accessibilityIdentifier("createMemory.titleField")
                    }

                    DatePicker(
                        "Date",
                        selection: $viewModel.memoryDate,
                        displayedComponents: .date
                    )
                    .accessibilityIdentifier("createMemory.datePicker")

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Journal · Optional")
                            .font(AppTheme.memoryTitle)

                        TextEditor(text: $viewModel.note)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 140)
                            .accessibilityLabel("Journal note")
                            .accessibilityIdentifier("createMemory.noteEditor")
                    }
                }
                .font(AppTheme.memoryBody)
                .foregroundStyle(AppTheme.forestGreen)
                .tint(AppTheme.forestGreen)
                .listRowBackground(AppTheme.parchment)
                .environment(\.colorScheme, .light)
                .disabled(isSaving)

                if let errorMessage {
                    Text(errorMessage)
                        .font(AppTheme.memoryBody)
                        .foregroundStyle(AppTheme.forestGreen)
                        .listRowBackground(AppTheme.parchment)
                        .accessibilityIdentifier("createMemory.error")
                }

                Button {
                    save()
                } label: {
                    HStack(spacing: 8) {
                        if isSaving {
                            ProgressView()
                                .tint(AppTheme.forestGreen)
                                .accessibilityIdentifier("createMemory.loading")
                        }

                        Text(isSaving ? "Saving…" : "Save Memory")
                    }
                    .font(AppTheme.memoryBody.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.parchment)
                .foregroundStyle(AppTheme.forestGreen)
                .listRowBackground(Color.clear)
                .disabled(!viewModel.canSave)
                .accessibilityIdentifier("createMemory.saveButton")
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.forestGreen.ignoresSafeArea())
            .navigationTitle("New Memory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.forestGreen, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSaving)
                    .tint(AppTheme.parchment)
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
