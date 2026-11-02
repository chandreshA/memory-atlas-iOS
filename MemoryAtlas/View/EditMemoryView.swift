//
//  EditMemoryView.swift
//  MemoryAtlas
//
//  Created by Chandresh Ahir on 10/21/26.
//

import SwiftUI

struct EditMemoryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EditMemoryViewModel
    private let onSaved: (Memory) -> Void

    init(
        viewModel: EditMemoryViewModel,
        onSaved: @escaping (Memory) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onSaved = onSaved
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(AppTheme.memoryTitle)

                        TextField("Title", text: $viewModel.title)
                            .padding(12)
                            .modifier(ArchiveInputSurface())
                            .accessibilityIdentifier("editMemory.titleField")
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date")
                            .font(AppTheme.memoryTitle)

                        DatePicker(
                            "Memory date",
                            selection: $viewModel.memoryDate,
                            displayedComponents: .date
                        )
                        .padding(12)
                        .modifier(ArchiveInputSurface())
                        .accessibilityIdentifier("editMemory.datePicker")
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Journal · Optional")
                            .font(AppTheme.memoryTitle)

                        TextEditor(text: $viewModel.note)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 180)
                            .padding(10)
                            .modifier(ArchiveInputSurface())
                            .accessibilityLabel("Journal note")
                            .accessibilityIdentifier("editMemory.noteEditor")
                    }
                }
                .disabled(viewModel.isSaving)
                .padding(24)
            }
            .foregroundStyle(AppTheme.inkGreen)
            .background {
                ArchivePaperSurface()
                    .ignoresSafeArea()
            }
            .navigationTitle("Edit Memory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(viewModel.isSaving)
                    .accessibilityIdentifier("editMemory.cancelButton")
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                saveControls
            }
            .tint(AppTheme.forestGreen)
            .interactiveDismissDisabled(viewModel.isSaving)
        }
    }
    private var saveControls: some View {
        VStack(spacing: 12) {
            if case .failed(let message) = viewModel.state {
                Text(message)
                    .font(AppTheme.memoryBody)
                    .foregroundStyle(AppTheme.inkGreen)
                    .accessibilityIdentifier("editMemory.error")
            }

            Button {
                save()
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isSaving {
                        ProgressView()
                    }

                    Text(viewModel.isSaving ? "Saving…" : "Save Changes")
                }
                .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canSave)
            .accessibilityIdentifier("editMemory.saveButton")
        }
        .padding(20)
        .background(AppTheme.parchment)
    }

    private func save() {
        Task {
            await viewModel.save()

            if case .saved(let updatedMemory) = viewModel.state {
                onSaved(updatedMemory)
                dismiss()
            }
        }
    }
}
