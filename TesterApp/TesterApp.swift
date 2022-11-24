//
//  TesterApp.swift
//  TesterApp
//
//  Created by Liam Rosenfeld on 11/23/22.
//
import SwiftUI

@main
struct TesterApp: App {
    var body: some Scene {
        WindowGroup {
            TesterAppView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        Settings {
            SettingsView(window: NSWindow())
                .frame(width: 300, height: 330)
        }
    }
}

struct TesterAppView: View {
    @State private var animation: Animation = .attractor
    
    var body: some View {
        VStack {
            Picker("Animation", selection: $animation) {
                ForEach(Animation.allCases) { animation in
                    Text(animation.name).tag(animation)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            
            GeometryReader { proxy in
                let frame = NSRect(origin: .zero, size: proxy.size)
                switch animation {
                case .fourier:
                    InertRepresentableView(FourierView(frame: frame))
                case .attractor:
                    AttractorView()
                case .hilbert:
                    InertRepresentableView(SquareHilbertView(frame: frame))
                case .maurer:
                    InertRepresentableView(MaurerView(frame: frame))
                case .perlin:
                    InertRepresentableView(PerlinView(frame: frame))
                }
            }
        }
    }
}

struct InertRepresentableView<T: NSView>: NSViewRepresentable {
    let internalView: T
    
    init(_ internalView: T) {
        self.internalView = internalView
    }
    
    func makeNSView(context: Context) -> T {
        internalView
    }
    
    func updateNSView(_ nsView: T, context: Context) { }
}

