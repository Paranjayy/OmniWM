import SwiftUI

struct WarpSwitcherEntry: Identifiable {
    let id: String
    let appName: String
    let windowTitle: String
    let icon: NSImage?
    let isSelected: Bool
}

struct WarpSwitcherHUD: View {
    let entries: [WarpSwitcherEntry]
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            // Full-screen click-to-dismiss scrim
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 0) {
                Spacer()

                // Card
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "rectangle.3.group")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.yellow)
                            Text("WARP SWITCHER")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.5))
                                .tracking(2)
                        }
                        Spacer()
                        Text("ESC to close")
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 24)

                    Divider()
                        .background(Color.white.opacity(0.08))
                        .padding(.horizontal, 20)

                    if entries.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "tray")
                                .font(.system(size: 32))
                                .foregroundStyle(.white.opacity(0.3))
                            Text("No managed windows")
                                .font(.system(size: 13))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                        .frame(height: 100)
                    } else {
                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 110, maximum: 150), spacing: 14)],
                            spacing: 14
                        ) {
                            ForEach(entries) { entry in
                                SwitcherItem(entry: entry, onTap: onDismiss)
                            }
                        }
                        .padding(.horizontal, 24)
                    }

                    // Footer hint
                    HStack(spacing: 16) {
                        KeyHint(key: "⌃⌥⌘W", label: "Open")
                        KeyHint(key: "ESC", label: "Close")
                        KeyHint(key: "Click", label: "Focus")
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 22)
                }
                .background {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.5), radius: 40, x: 0, y: 20)
                }
                .frame(maxWidth: 760)
                .padding(.horizontal, 40)

                Spacer()
            }
        }
    }
}

private struct KeyHint: View {
    let key: String
    let label: String

    var body: some View {
        HStack(spacing: 5) {
            Text(key)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.4))
        }
    }
}

private struct SwitcherItem: View {
    let entry: WarpSwitcherEntry
    let onTap: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            isHovered || entry.isSelected
                            ? Color.white.opacity(0.18)
                            : Color.white.opacity(0.06)
                        )
                        .frame(width: 60, height: 60)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(
                                    entry.isSelected ? Color.yellow.opacity(0.4) : Color.clear,
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(
                            color: entry.isSelected ? .yellow.opacity(0.25) : .clear,
                            radius: 8
                        )

                    if let icon = entry.icon {
                        Image(nsImage: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 38, height: 38)
                    } else {
                        Image(systemName: "app.dashed")
                            .font(.system(size: 22))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                }

                Text(entry.appName)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(entry.isSelected || isHovered ? .white : .white.opacity(0.65))
                    .lineLimit(1)

                Text(entry.windowTitle)
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.35))
                    .lineLimit(1)
            }
            .scaleEffect(isHovered ? 1.06 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.65), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}
