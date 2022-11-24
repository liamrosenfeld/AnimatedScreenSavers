//
//  SettingsStore.swift
//  AnimatedScreenSavers
//
//  Created by Liam Rosenfeld on 11/23/22.
//

import Foundation

enum Animation: CaseIterable, Identifiable {
    case fourier
    case attractor
    case hilbert
    case maurer
    case perlin
    
    var name: String {
        switch self {
        case .fourier:
            return "Fourier Artist"
        case .attractor:
            return "Chaotic Attractor"
        case .hilbert:
            return "Pseudo Hilbert Curve"
        case .maurer:
            return "Maurer Rose"
        case .perlin:
            return "Perlin Noise Mesh"
        }
    }
    
    var id: Int {
        switch self {
        case .fourier:
            return 0
        case .attractor:
            return 1
        case .hilbert:
            return 2
        case .maurer:
            return 3
        case .perlin:
            return 4
        }
    }
    
    var keypath: WritableKeyPath<EnabledAnimations, Bool> {
        switch self {
        case .fourier:
            return \.fourier
        case .attractor:
            return \.attractor
        case .hilbert:
            return \.hilbert
        case .maurer:
            return \.maurer
        case .perlin:
            return \.perlin
        }
    }
}

struct EnabledAnimations: Codable, Equatable {
    var attractor: Bool = true
    var fourier: Bool = true
    var hilbert: Bool = true
    var maurer: Bool = true
    var perlin: Bool = true
    
    func toSet() -> Set<Animation> {
        var set = Set<Animation>()
        if attractor { set.insert(.attractor) }
        if fourier { set.insert(.fourier) }
        if hilbert { set.insert(.hilbert) }
        if maurer { set.insert(.maurer) }
        if perlin { set.insert(.perlin) }
        return set
    }
}

struct SettingsStore: Codable, Equatable {
    var animations: EnabledAnimations = .init()
    
    static func loadFromFile() -> SettingsStore {
        let existingFilesData = try! Data(contentsOf: Paths.settingsFile)
        return (try? JSONDecoder().decode(Self.self, from: existingFilesData)) ?? SettingsStore()
    }
    
    func saveToFile() {
        let data = try! JSONEncoder().encode(self)
        FileManager.default.createFile(atPath: Paths.settingsFile.path, contents: data, attributes: nil)
    }
}
