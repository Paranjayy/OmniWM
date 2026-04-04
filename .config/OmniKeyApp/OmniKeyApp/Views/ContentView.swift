import SwiftUI

// MARK: - Main Layout

struct ContentView: View {
    @StateObject private var store = LayerStore()
    @State private var selectedTab = 0

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            TabView(selection: $selectedTab) {
                LayersView(store: store)
                    .tabItem { Label("Layers", systemImage: "square.stack.3d.up") }
                    .tag(0)

                SequencesView(store: store)
                    .tabItem { Label("Sequences", systemImage: "arrow.right.arrow.right") }
                    .tag(1)

                KeyboardView(store: store)
                    .tabItem { Label("Visual Map", systemImage: "keyboard") }
                    .tag(2)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { store.deployToKarabiner() }) {
                        Label("Deploy to Karabiner", systemImage: "arrow.up.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
            }
        }
    }

    var sidebar: some View {
        List {
            Label("Layers (\(store.layers.count))", systemImage: "square.stack.3d.up")
            Label("Sequences (\(store.sequences.count))", systemImage: "arrow.right.arrow.right")
            Label("Visual Map", systemImage: "keyboard")
            Divider()
            Label("Deploy", systemImage: "arrow.up.circle")
        }
        .navigationTitle("OmniKey")
    }
}

// MARK: - Layers View

struct LayersView: View {
    @ObservedObject var store: LayerStore
    @State private var selectedLayer: KeyLayer?

    var body: some View {
        HSplitView {
            // Layer List
            List(store.layers, selection: $selectedLayer) { layer in
                VStack(alignment: .leading, spacing: 2) {
                    Text(layer.name).font(.headline)
                    Text("Trigger: \(layer.triggerKey) • \(layer.mappings.count) mappings")
                        .font(.caption).foregroundColor(.secondary)
                    if let ctx = layer.appContext {
                        Text("App: \(ctx)").font(.caption2).foregroundColor(.blue)
                    }
                }
                .padding(.vertical, 4)
                .tag(layer as KeyLayer?)
            }
            .frame(minWidth: 220, maxWidth: 280)

            // Mapping Editor
            if let layer = selectedLayer,
               let idx = store.layers.firstIndex(where: { $0.id == layer.id }) {
                MappingEditorView(layer: $store.layers[idx])
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "square.stack.3d.up")
                        .font(.system(size: 48)).foregroundColor(.secondary)
                    Text("Select a layer to edit").foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

// MARK: - Mapping Editor

struct MappingEditorView: View {
    @Binding var layer: KeyLayer

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading) {
                    Text(layer.name).font(.title2.bold())
                    Text("Trigger: \(layer.triggerKey) • Tap sends itself: \(layer.tapSendsSelf ? "Yes" : "No")")
                        .font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                Button("+ Add Mapping") {
                    layer.mappings.append(KeyMapping(fromKey: "", toKey: "", modifiers: [], description: "New mapping"))
                }
            }
            .padding()

            Divider()

            if layer.mappings.isEmpty {
                Spacer()
                Text("No mappings yet. Add one above.").foregroundColor(.secondary)
                    .frame(maxWidth: .infinity).padding()
                Spacer()
            } else {
                Table(layer.mappings) {
                    TableColumn("Hold Key") { m in Text(m.fromKey).font(.system(.body, design: .monospaced)) }
                    TableColumn("Sends") { m in Text(m.toKey).font(.system(.body, design: .monospaced)) }
                    TableColumn("Modifiers") { m in Text(m.modifiers.joined(separator: "+")).foregroundColor(.blue) }
                    TableColumn("Description") { m in Text(m.description).foregroundColor(.secondary) }
                }
            }
        }
    }
}

// MARK: - Sequences View

struct SequencesView: View {
    @ObservedObject var store: LayerStore

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Hyper Sequences").font(.title2.bold())
                Text("(Hyper = Caps Lock = ⌘+⌥+⌃+⇧)").foregroundColor(.secondary)
                Spacer()
                Button("+ Add") { }
            }
            .padding()
            Divider()

            Table(store.sequences) {
                TableColumn("Name") { s in Text(s.name) }
                TableColumn("Sequence") { s in
                    Text("Hyper → \(s.leaderKey.uppercased()) → \(s.followKey.uppercased())")
                        .font(.system(.body, design: .monospaced))
                }
                TableColumn("Action") { s in
                    switch s.action {
                    case .launchApp(let app): Text("Launch \(app)").foregroundColor(.green)
                    case .sendKey(let k, let m): Text("Send: \(m.joined(separator: "+"))+\(k)").foregroundColor(.blue)
                    case .shellCommand(let cmd): Text(cmd).foregroundColor(.orange)
                    }
                }
            }
        }
    }
}

// MARK: - Visual Keyboard View

let KEYBOARD_ROWS: [[String]] = [
    ["`","1","2","3","4","5","6","7","8","9","0","-","="],
    ["q","w","e","r","t","y","u","i","o","p","[","]","\\"],
    ["a","s","d","f","g","h","j","k","l",";","'"],
    ["z","x","c","v","b","n","m",",",".","/"]
]

struct KeyboardView: View {
    @ObservedObject var store: LayerStore
    @State private var selectedLayerName = "Right Cmd Layer"

    var activeLayer: KeyLayer? {
        store.layers.first(where: { $0.name.contains("Cmd") || $0.name == selectedLayerName })
    }

    var body: some View {
        VStack(spacing: 16) {
            Picker("Show Layer:", selection: $selectedLayerName) {
                ForEach(store.layers) { l in
                    Text(l.name).tag(l.name)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            VStack(spacing: 6) {
                ForEach(KEYBOARD_ROWS, id: \.self) { row in
                    HStack(spacing: 4) {
                        ForEach(row, id: \.self) { key in
                            KeyCapView(
                                key: key,
                                mapping: activeLayer?.mappings.first(where: { $0.fromKey == key })
                            )
                        }
                    }
                }
            }
            .padding()

            HStack {
                Circle().fill(.green).frame(width: 10, height: 10)
                Text("Has mapping in selected layer")
                Circle().fill(Color(.windowBackgroundColor)).frame(width: 10, height: 10)
                    .overlay(Circle().stroke(.secondary, lineWidth: 1))
                Text("No mapping (passes through)")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct KeyCapView: View {
    let key: String
    let mapping: KeyMapping?

    var body: some View {
        VStack(spacing: 2) {
            Text(key.uppercased())
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
            if let m = mapping {
                Text(m.toKey.replacingOccurrences(of: "_arrow", with: "↑").prefix(4))
                    .font(.system(size: 8))
                    .foregroundColor(.white)
            }
        }
        .frame(width: 36, height: 36)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(mapping != nil ? Color.blue : Color(.controlBackgroundColor))
                .shadow(radius: mapping != nil ? 2 : 0)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 0.5)
        )
        .foregroundColor(mapping != nil ? .white : .primary)
    }
}
