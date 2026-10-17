//
//  MemoryTimelineRow.swift
//  MemoryAtlas
//
//  Created by Chandresh Ahir on 10/5/26.
//

import SwiftUI

struct MemoryTimelineRow: View {
    let memory: Memory

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 12) {
                    Text(
                        memory.memoryDate,
                        format: .dateTime.month(.wide).day().year()
                    )
                    .font(AppTheme.memoryTitle)
                    .foregroundStyle(AppTheme.forestGreen)

                    memoryCard
                }
                .padding(.bottom, 20)
            } else {
                HStack(alignment: .top, spacing: 10) {
                    VStack(spacing: 10) {
                        Circle()
                            .fill(AppTheme.forestGreen)
                            .frame(width: 9, height: 9)
                            .accessibilityHidden(true)

                        dateLabel
                            .padding(.vertical, 6)
                            .frame(maxWidth: .infinity)
                            .background(AppTheme.sageGreen)
                    }
                    .frame(width: 44)
                    .padding(.top, 14)

                    memoryCard
                }
                .padding(.bottom, 20)
                .background(alignment: .leading) {
                    Rectangle()
                        .fill(AppTheme.forestGreen.opacity(0.4))
                        .frame(width: 1)
                        .offset(x: 21.5)
                        .accessibilityHidden(true)
                        .allowsHitTesting(false)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var dateLabel: some View {
        VStack(spacing: 2) {
            Text(memory.memoryDate, format: .dateTime.month(.abbreviated))
                .font(AppTheme.memoryDate)
                .textCase(.uppercase)

            Text(memory.memoryDate, format: .dateTime.day())
                .font(.system(.title2, design: .serif))
                .fontWeight(.semibold)

            Text(memory.memoryDate, format: .dateTime.year())
                .font(AppTheme.memoryDate)
        }
        .monospacedDigit()
        .foregroundStyle(AppTheme.inkGreen)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            Text(
                memory.memoryDate,
                format: .dateTime.month(.wide).day().year()
            )
        )
    }

    private var memoryCard: some View {
        Group {
            if let note = memory.note,
               !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                journalCard(note: note)
            } else if dynamicTypeSize.isAccessibilitySize {
                Text(memory.title)
                    .font(AppTheme.memoryTitle)
                    .foregroundStyle(AppTheme.inkGreen)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background { ArchivePaperSurface() }
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                looseEntry
            }
        }
    }

    private func journalCard(note: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(memory.title)
                .font(AppTheme.memoryTitle)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .top, spacing: 12) {
                Text(note)
                    .font(.subheadline)
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

                if !dynamicTypeSize.isAccessibilitySize {
                    MemoryDateStampView(date: memory.memoryDate)
                        .fixedSize()
                        .accessibilityHidden(true)
                }
            }
        }
        .foregroundStyle(AppTheme.forestGreen)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, dynamicTypeSize.isAccessibilitySize ? 0 : 16)
        .padding(14)
        .background { ArchivePaperSurface() }
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay(alignment: .trailing) {
            if !dynamicTypeSize.isAccessibilitySize {
                ArchiveFloralBorder(width: 12, color: AppTheme.forestGreen.opacity(0.6))
                    .padding(.vertical, 10)
                    .padding(.trailing, 5)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 4)
                .strokeBorder(
                    AppTheme.forestGreen.opacity(0.25),
                    lineWidth: 1
                )
        }
        .shadow(
            color: AppTheme.forestGreen.opacity(0.12),
            radius: 3,
            x: 0,
            y: 2
        )
    }

    private var looseEntry: some View {
        HStack(alignment: .center, spacing: 14) {
            BotanicalAccentView(color: AppTheme.forestGreen, length: 54)
                .frame(width: 60, height: 78)
                .padding(6)
                .background { ArchivePaperSurface() }
                .overlay {
                    Rectangle().strokeBorder(AppTheme.forestGreen.opacity(0.2))
                }
                .rotationEffect(.degrees(-4))
                .shadow(color: AppTheme.forestGreen.opacity(0.2), radius: 2, x: 1, y: 2)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 16) {
                Text(memory.title)
                    .font(AppTheme.memoryTitle)
                    .foregroundStyle(AppTheme.inkGreen)
                    .fixedSize(horizontal: false, vertical: true)

                ArchivePostmark()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
    }
}
