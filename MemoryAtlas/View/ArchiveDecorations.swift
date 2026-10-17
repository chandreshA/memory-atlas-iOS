import SwiftUI

/// Decorative surfaces never intercept input or become VoiceOver elements.
struct ArchivePaperSurface: View {
    var tint: Color = AppTheme.parchment
    var textureOpacity: Double = 0.55

    var body: some View {
        tint
            .overlay {
                GeometryReader { geometry in
                    Image("ArchivePaperTexture")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .blendMode(.multiply)
                        .opacity(textureOpacity)
                }
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

struct ArchiveFloralBorder: View {
    var width: CGFloat = 38
    var color: Color? = nil

    var body: some View {
        GeometryReader { geometry in
            let imageWidth = width * 1.4
            let tileHeight = imageWidth * 3
            let count = max(1, Int((geometry.size.height / tileHeight).rounded(.up)))

            VStack(spacing: 0) {
                ForEach(0..<count, id: \.self) { _ in
                    Image("FloralBinding")
                        .resizable()
                        .renderingMode(color == nil ? .original : .template)
                        .scaledToFit()
                        .foregroundStyle(color ?? AppTheme.parchment)
                        .frame(width: imageWidth, height: tileHeight)
                }
            }
            .frame(width: geometry.size.width)
        }
        .frame(width: width)
        .clipped()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct ArchiveMonthHeading: View {
    let date: Date

    var body: some View {
        HStack(spacing: 12) {
            Text(date, format: .dateTime.month(.wide).year())
                .textCase(.uppercase)
                .font(.caption.weight(.semibold))
                .tracking(2)
                .fixedSize(horizontal: false, vertical: true)

            Rectangle()
                .fill(AppTheme.forestGreen.opacity(0.45))
                .frame(height: 1)
                .accessibilityHidden(true)
        }
        .foregroundStyle(AppTheme.inkGreen)
        .padding(.bottom, 16)
        .accessibilityAddTraits(.isHeader)
    }
}

struct ArchivePostmark: View {
    var body: some View {
        Text("MEMORY")
            .font(.caption.monospaced().weight(.medium))
            .tracking(2)
            .foregroundStyle(AppTheme.stampRed)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .overlay {
                RoundedRectangle(cornerRadius: 2)
                    .strokeBorder(AppTheme.stampRed.opacity(0.85), lineWidth: 1)
            }
            .rotationEffect(.degrees(-8))
            .accessibilityHidden(true)
            .allowsHitTesting(false)
    }
}

struct ArchiveInputSurface: ViewModifier {
    func body(content: Content) -> some View {
        content.background {
            ArchivePaperSurface(tint: AppTheme.sageGreen, textureOpacity: 0.24)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay {
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(AppTheme.parchment.opacity(0.4), lineWidth: 0.8)
                }
                .shadow(color: AppTheme.inkGreen.opacity(0.18), radius: 2, x: 0, y: 1)
        }
    }
}
