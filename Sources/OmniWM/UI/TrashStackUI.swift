import SwiftUI

struct TrashStackEntry: Identifiable {
    let id: UUID
    let appName: String
    let windowTitle: String
    let icon: NSImage?
    let timestamp: Date
}

struct TrashVisualizerHUD: View {
    let entries: [TrashStackEntry]
    
    var body: some View {
        HStack(spacing: 12) {
            // Visual Stack indicator
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "trash.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.orange)
            }
            .shadow(color: .orange.opacity(0.2), radius: 10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Recently Trashed")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
                
                HStack(spacing: 8) {
                    ForEach(entries.prefix(3)) { entry in
                        TrashedItemThumb(entry: entry)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct TrashedItemThumb: View {
    let entry: TrashStackEntry
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(0.08))
                .frame(width: 32, height: 32)
            
            if let icon = entry.icon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 20, height: 20)
            } else {
                Image(systemName: "app")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.3))
            }
        }
        .help("\(entry.appName): \(entry.windowTitle)")
    }
}
