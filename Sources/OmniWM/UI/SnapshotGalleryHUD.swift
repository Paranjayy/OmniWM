import SwiftUI

struct SnapshotGalleryHUD: View {
    let snapshots: [WorkspaceSnapshotManager.Snapshot]
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        ZStack {
            // HUD Background
            VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 10)
            
            VStack(spacing: 30) {
                HStack {
                    Image(systemName: "camera.viewfinder")
                    Text("Snapshot Gallery")
                }
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.6))
                
                // Carousel View
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        ForEach(Array(snapshots.enumerated()), id: \.element.id) { index, snapshot in
                            SnapshotTile(snapshot: snapshot, isSelected: index == selectedIndex)
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        selectedIndex = index
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 40)
                }
                
                // Restore Button (Floating)
                Button(action: {
                    // Logic to restore the snapshot
                    HapticManager.shared.trigger(.sharpClick)
                }) {
                    Text("Restore Layout")
                        .font(.system(size: 13, weight: .bold))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 40)
        }
        .frame(width: 700, height: 400)
    }
}

struct SnapshotTile: View {
    let snapshot: WorkspaceSnapshotManager.Snapshot
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Window Layout Preview Placeholder
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 200, height: 120)
                    .overlay(
                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.1)).frame(width: 60, height: 80)
                                RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.1)).frame(width: 100, height: 80)
                            }
                        }
                    )
                
                if isSelected {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.blue, lineWidth: 3)
                        .shadow(color: .blue.opacity(0.5), radius: 10)
                }
            }
            
            Text(snapshot.timestamp, style: .time)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(isSelected ? .white : .white.opacity(0.5))
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.interactiveSpring(), value: isSelected)
    }
}
