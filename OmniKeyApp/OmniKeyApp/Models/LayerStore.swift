import SwiftUI

class KeyLayer: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var triggerKey: String
    var tapSendsSelf: Bool
    var mappings: [KeyMapping]
    var appContext: String?

    init(name: String, trigger: String, tap: Bool, mappings: [KeyMapping], context: String? = nil) {
        self.name = name
        self.triggerKey = trigger
        self.tapSendsSelf = tap
        self.mappings = mappings
        self.appContext = context
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: KeyLayer, rhs: KeyLayer) -> Bool { lhs.id == rhs.id }
}

struct KeyMapping: Identifiable {
    let id = UUID()
    var fromKey: String
    var toKey: String
    var modifiers: [String]
    var description: String
}

enum SequenceAction {
    case launchApp(String)
    case sendKey(String, [String])
    case shellCommand(String)
}

struct KeySequence: Identifiable {
    let id = UUID()
    var name: String
    var leaderKey: String
    var followKey: String
    var action: SequenceAction
}

class LayerStore: ObservableObject {
    @Published var layers: [KeyLayer] = []
    @Published var sequences: [KeySequence] = []

    init() {
        // Sample data matching the current v5 config
        let navLayer = KeyLayer(
            name: "Right Opt Layer",
            trigger: "right_option",
            tap: true,
            mappings: [
                KeyMapping(fromKey: "h", toKey: "left_arrow", modifiers: ["option"], description: "Word Left"),
                KeyMapping(fromKey: "l", toKey: "right_arrow", modifiers: ["option"], description: "Word Right"),
                KeyMapping(fromKey: "j", toKey: "page_down", modifiers: [], description: "Page Down"),
                KeyMapping(fromKey: "k", toKey: "page_up", modifiers: [], description: "Page Up"),
                KeyMapping(fromKey: "u", toKey: "left_arrow", modifiers: ["command"], description: "Line Start"),
                KeyMapping(fromKey: "o", toKey: "right_arrow", modifiers: ["command"], description: "Line End"),
                KeyMapping(fromKey: "comma", toKey: "z", modifiers: ["command"], description: "Undo"),
                KeyMapping(fromKey: "period", toKey: "z", modifiers: ["command", "shift"], description: "Redo")
            ]
        )

        let rcmdLayer = KeyLayer(
            name: "RCmd Layer",
            trigger: "right_command",
            tap: true,
            mappings: [
                KeyMapping(fromKey: "1-9", toKey: "1-9", modifiers: ["option"], description: "Switch Workspace"),
                KeyMapping(fromKey: "w", toKey: "up_arrow", modifiers: ["control"], description: "Focus Up"),
                KeyMapping(fromKey: "a", toKey: "left_arrow", modifiers: ["control"], description: "Focus Left"),
                KeyMapping(fromKey: "s", toKey: "down_arrow", modifiers: ["control"], description: "Focus Down"),
                KeyMapping(fromKey: "d", toKey: "right_arrow", modifiers: ["control"], description: "Focus Right"),
                KeyMapping(fromKey: "h", toKey: "left_arrow", modifiers: [], description: "Arrow Left"),
                KeyMapping(fromKey: "l", toKey: "right_arrow", modifiers: [], description: "Arrow Right"),
                KeyMapping(fromKey: "j", toKey: "down_arrow", modifiers: [], description: "Arrow Down"),
                KeyMapping(fromKey: "k", toKey: "up_arrow", modifiers: [], description: "Arrow Up"),
                KeyMapping(fromKey: "tab", toKey: "tab", modifiers: ["option", "control"], description: "Back and Forth")
            ]
        )

        let arcLayer = KeyLayer(
            name: "Arc Context",
            trigger: "right_command",
            tap: true,
            mappings: [
                KeyMapping(fromKey: "1-9", toKey: "1-9", modifiers: ["command"], description: "Arc Tab Switch")
            ],
            context: "company.thebrowser.Browser"
        )

        self.layers = [navLayer, rcmdLayer, arcLayer]

        self.sequences = [
            KeySequence(name: "Launch Arc", leaderKey: "a", followKey: "a", action: .launchApp("Arc")),
            KeySequence(name: "Launch Cursor", leaderKey: "a", followKey: "c", action: .launchApp("Cursor")),
            KeySequence(name: "Lock Screen", leaderKey: "s", followKey: "l", action: .shellCommand("pmset displaysleepnow")),
            KeySequence(name: "Move to WS 1", leaderKey: "w", followKey: "1", action: .sendKey("1", ["option", "shift"]))
        ]
    }

    func deployToKarabiner() -> String {
        var rules: [String: Any] = [
            "title": "OmniKey GUI Export",
            "rules": []
        ]
        
        var ruleList: [[String: Any]] = []
        
        // 1. Generate Layer Triggers
        for layer in layers {
            let triggerRule: [String: Any] = [
                "description": "[Trigger] \(layer.name)",
                "manipulators": [
                    [
                        "type": "basic",
                        "from": [ "key_code": layer.triggerKey, "modifiers": [ "optional": ["any"] ] ],
                        "to": [ [ "set_variable": [ "name": "\(layer.triggerKey)_layer", "value": 1 ] ] ],
                        "to_after_key_up": [ [ "set_variable": [ "name": "\(layer.triggerKey)_layer", "value": 0 ] ] ],
                        "to_if_alone": layer.tapSendsSelf ? [[ "key_code": layer.triggerKey ]] : []
                    ]
                ]
            ]
            ruleList.append(triggerRule)
        }
        
        // 2. Generate Mappings
        for layer in layers {
            var manipulators: [[String: Any]] = []
            for mapping in layer.mappings {
                let m: [String: Any] = [
                    "type": "basic",
                    "from": [ "key_code": mapping.fromKey ],
                    "to": [ [ "key_code": mapping.toKey, "modifiers": mapping.modifiers ] ],
                    "conditions": [
                        [ "type": "variable_if", "name": "\(layer.triggerKey)_layer", "value": 1 ]
                    ]
                ]
                manipulators.append(m)
            }
            
            let mapRule: [String: Any] = [
                "description": "[Layer] \(layer.name) Mappings",
                "manipulators": manipulators
            ]
            ruleList.append(mapRule)
        }
        
        rules["rules"] = ruleList
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: rules, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
            return jsonString
        }
        
        return ""
    }
}
