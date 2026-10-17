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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
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
        if case .failed(let message) = viewModel.state {
            return message
        }

        return nil
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(AppTheme.memoryTitle)

                            TextField(
                                "Title",
                                text: $viewModel.title,
                                prompt: Text("Give this memory a title")
                                    .foregroundStyle(AppTheme.inkGreen)
                            )
                            .foregroundStyle(AppTheme.inkGreen)
                            .padding(12)
                            .modifier(ArchiveInputSurface())
                            .accessibilityLabel("Title")
                            .accessibilityIdentifier("createMemory.titleField")
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date")
                                .font(AppTheme.memoryTitle)

                            HStack(spacing: 12) {
                                DatePicker(
                                    "Memory date",
                                    selection: $viewModel.memoryDate,
                                    displayedComponents: .date
                                )
                                .foregroundStyle(AppTheme.inkGreen)
                                .labelsHidden()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                                .modifier(ArchiveInputSurface())
                                .accessibilityLabel("Memory date")
                                .accessibilityIdentifier("createMemory.datePicker")

                                if !dynamicTypeSize.isAccessibilitySize {
                                    MemoryDateStampView(date: viewModel.memoryDate)
                                        .fixedSize()
                                        .accessibilityHidden(true)
                                        .allowsHitTesting(false)
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                Text("Journal · Optional")
                                    .font(AppTheme.memoryTitle)
                                    .fixedSize(horizontal: false, vertical: true)

                                Spacer(minLength: 0)

                                BotanicalAccentView(length: 42)
                            }

                            TextEditor(text: $viewModel.note)
                                .foregroundStyle(AppTheme.inkGreen)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 156)
                                .containerRelativeFrame(.vertical) { height, _ in
                                    max(156, height * 0.5)
                                }
                                .padding(.trailing, dynamicTypeSize.isAccessibilitySize ? 0 : 26)
                                .padding(10)
                                .modifier(ArchiveInputSurface())
                                .overlay(alignment: .trailing) {
                                    if !dynamicTypeSize.isAccessibilitySize {
                                        ArchiveFloralBorder(width: 16, color: AppTheme.forestGreen.opacity(0.65))
                                            .padding(.vertical, 8)
                                            .padding(.trailing, 8)
                                    }
                                }
                                .overlay(alignment: .topLeading) {
                                    if viewModel.note.isEmpty {
                                        Text("What happened? How did it feel?\nWhat do you want to remember?")
                                            .font(AppTheme.memoryBody)
                                            .foregroundStyle(AppTheme.inkGreen)
                                            .padding(.leading, 15)
                                            .padding(.top, 18)
                                            .padding(.trailing, 42)
                                            .allowsHitTesting(false)
                                            .accessibilityHidden(true)
                                    }
                                }
                                .accessibilityLabel("Journal note")
                                .accessibilityIdentifier("createMemory.noteEditor")
                        }
                    }
                    .font(AppTheme.memoryBody)
                    .foregroundStyle(AppTheme.parchment)
                    .tint(AppTheme.forestGreen)
                    .environment(\.colorScheme, .light)
                    .disabled(isSaving)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(AppTheme.memoryBody)
                            .foregroundStyle(AppTheme.forestGreen)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background {
                                ArchivePaperSurface()
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                            .accessibilityIdentifier("createMemory.error")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(AppTheme.forestGreen.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                formHeader
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                saveButton
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 12)
                    .background(AppTheme.forestGreen)
            }
        }
    }

    private var saveButton: some View {
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
            .font(AppTheme.memoryTitle)
            .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(ArchiveSaveButtonStyle())
        .disabled(!viewModel.canSave)
        .accessibilityIdentifier("createMemory.saveButton")
    }

    private var formHeader: some View {
        HStack(alignment: .center, spacing: 8) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .disabled(isSaving)
            .accessibilityLabel("Cancel new memory")
            .accessibilityIdentifier("createMemory.cancelButton")

            Text("New Memory")
                .font(.system(.largeTitle, design: .serif))
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 1)
                .minimumScaleFactor(0.85)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .accessibilityAddTraits(.isHeader)

            Color.clear
                .frame(width: 44, height: 44)
                .accessibilityHidden(true)
        }
        .foregroundStyle(AppTheme.parchment)
        .padding(.horizontal, 12)
        .padding(.top, 4)
        .padding(.bottom, 8)
        .background(AppTheme.forestGreen)
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

private struct ArchiveSaveButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 4)
            .foregroundStyle(AppTheme.forestGreen)
            .background(
                isEnabled ? AppTheme.parchment : AppTheme.sageGreen.opacity(0.65),
                in: Capsule()
            )
            .overlay {
                Capsule().strokeBorder(AppTheme.parchment.opacity(isEnabled ? 0.6 : 0.2))
            }
            .opacity(configuration.isPressed && isEnabled ? 0.85 : 1)
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

    #Preview("New Memory · Filled") {
        let viewModel = CreateMemoryViewModel(
            memoryRepository: CreateMemoryPreviewRepository()
        )
        viewModel.title = "An ordinary Sunday"
        viewModel.note = "A quiet morning, a good book, and nowhere to rush."

        return CreateMemoryView(viewModel: viewModel)
    }

    #Preview("New Memory · Large Text") {
        CreateMemoryView(
            viewModel: CreateMemoryViewModel(
                memoryRepository: CreateMemoryPreviewRepository()
            )
        )
        .environment(\.dynamicTypeSize, .accessibility3)
    }

#endif
