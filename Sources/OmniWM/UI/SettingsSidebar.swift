import SwiftUI

struct SettingsSidebar: View {
    @Bindable var settings: SettingsStore
    @Binding var selection: SettingsSection

    var body: some View {
        List(SettingsSection.allCases, selection: $selection) { section in
            Label {
                HStack {
                    Text(section.displayName)
                    Spacer()
                    if section == .godBuild {
                        if settings.activeProfile == .godBuild {
                            Text("ON")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Color.yellow)
                                .clipShape(Capsule())
                        } else {
                            Circle()
                                .frame(width: 6, height: 6)
                                .foregroundStyle(.orange.opacity(0.7))
                        }
                    }
                }
            } icon: {
                Image(systemName: section.icon)
                    .foregroundStyle(
                        section == .godBuild && settings.activeProfile == .godBuild
                        ? .yellow : .primary
                    )
            }
            .tag(section)
        }
        .listStyle(.sidebar)
        .navigationTitle("OmniWM")
    }
}
