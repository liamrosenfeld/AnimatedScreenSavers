//
//  SettingsView.swift
//  AnimatedScreenSavers
//
//  Created by Liam Rosenfeld on 11/22/22.
//

import SwiftUI

struct SettingsView: View {
    var window: NSWindow
    
    @State private var settings = SettingsStore()
    
    var body: some View {
        VStack {
            Form {
                Section("Enabled Animations") {
                    ForEach(Animation.allCases) { animation in
                        // using keypaths complicates things a bit but makes it so adding new animations
                        // throws a compiler error until the proper support in settings is added
                        Toggle(
                            animation.name,
                            isOn: $settings.animations[dynamicMember: animation.keypath]
                        )
                    }
                }
            }
            .formStyle(.grouped)
            
            HStack {
                Button("Cancel", action: close)
                    .keyboardShortcut(.cancelAction)
                Button("Ok", action: apply)
                    .keyboardShortcut(.defaultAction)
            }
            
            Spacer()
            
            Divider()
            
            Text("Made with <3 by Liam Rosenfeld")
            Text("[Source Code](https://github.com/liamrosenfeld/AnimatedScreenSavers)")
        }
        .onAppear(perform: appeared)
    }
    
    func appeared() {
        settings = SettingsStore.loadFromFile()
    }
    
    func close() {
        window.sheetParent?.endSheet(window)
    }
    
    func apply() {
        settings.saveToFile()
        close()
    }
}
