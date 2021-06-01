//
//  AttractorView.swift
//  AnimatedScreenSavers
//
//  Created by Liam Rosenfeld on 5/31/21.
//

import SwiftUI

struct AttractorView: View {
    let calculator = AttractorCalculator()
    
    @State var attractor: Attractor = .lorenz()
    @State var initialCondition: SIMD3<Float> = .init(0, 0, 0)
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .bottom)) {
            GeometryReader { geometry in
                AttractorVisViewHost(calc: calculator, frame: NSRect(origin: .zero, size: geometry.size))
            }
            AttractorInfo(attractor: attractor, initCond: initialCondition)
                .padding()
        }.onReceive(calculator.newAttractor) { (attractor, initialCondition) in
            self.attractor = attractor
            self.initialCondition = initialCondition
        }
    }
}

struct AttractorInfo: View {
    let attractor: Attractor
    let initCond: SIMD3<Float>
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(attractor.name) Attractor")
                .font(.title3)
                .padding(0.2)
            Text(attractor.equations)
            Text("where")
                .padding(0.2)
            Text(attractor.constants)
            Text("and")
                .padding(0.2)
            Text("initial condition =")
            Text(String(format: "(%.4f, %.4f, %.4f)", initCond.x, initCond.y, initCond.z))
        }
        .padding()
        .background(Color.gray.opacity(0.4))
        .cornerRadius(5)
    }
}

struct AttractorVisViewHost: NSViewRepresentable {
    let calc: AttractorCalculator
    let frame: NSRect
    
    func makeNSView(context: Context) -> AttractorVisView {
        return AttractorVisView(calc: calc, frame: frame)
    }
    
    func updateNSView(_ nsView: AttractorVisView, context: Context) { }
}
