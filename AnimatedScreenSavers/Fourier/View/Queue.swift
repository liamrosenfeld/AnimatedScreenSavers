//
//  PathsQueue.swift
//  AnimatedScreenSavers
//
//  Created by Liam Rosenfeld on 5/27/21.
//

import Foundation

class Queue {
    private let files = ["swift", "treble"]
    private var index = -1
    private var epicycles = [[Wave]]()
    
    func loadIn() {
        files.forEach { file in
            let points = points(from: file)
            epicycles.append(dft(points))
        }
    }
    
    func next() -> [Wave] {
        index = (index + 1) % epicycles.count
        return epicycles[index]
    }
    
    private func points(from file: String) -> [CGPoint] {
        guard let url = Bundle(for: Self.self).url(forResource: file, withExtension: "json"),
              let jsonData = try? Data(contentsOf: url)
        else {
            return []
        }
        
        let points = try? JSONDecoder().decode([CGPoint].self, from: jsonData)
        return points ?? []
    }
}
