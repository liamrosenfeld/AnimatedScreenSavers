//
//  FourierQueue.swift
//  AnimatedScreenSavers
//
//  Created by Liam Rosenfeld on 5/27/21.
//

import Foundation

@MainActor
class FourierQueue {
    private let files = [
        "swift",
        "treble",
        "heart",
        "ferris",
        "fourier",
        "square",
    ]
    
    private var index = -1
    private var epicycles = [[Wave]]()
    
    func loadIn() {
        let shuffledFiles = files.shuffled()
        
        // wait for the first to complete
        let points = getPoints(from: shuffledFiles[0])
        epicycles.append(dft(points))
        
        // do the rest in the background
        Task.detached { [self] in
            for file in shuffledFiles.dropFirst() {
                let points = await getPoints(from: file)
                let result = dft(points)
                await MainActor.run {
                    epicycles.append(result)
                }
            }
        }
    }
    
    func next() -> [Wave] {
        index = (index + 1) % epicycles.count
        return epicycles[index]
    }
    
    private func getPoints(from file: String) -> [CGPoint] {
        guard let url = Bundle(for: Self.self).url(forResource: file, withExtension: "json"),
              let jsonData = try? Data(contentsOf: url)
        else {
            return []
        }
        
        let points = try? JSONDecoder().decode([CGPoint].self, from: jsonData)
        return points ?? []
    }
}
