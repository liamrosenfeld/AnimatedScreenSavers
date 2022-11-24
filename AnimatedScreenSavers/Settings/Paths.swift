//
//  Paths.swift
//  AnimatedScreenSavers
//
//  Created by Liam Rosenfeld on 11/23/22.
//

import Foundation

enum Paths {
    static var settingsFile: URL = {
        return rootFile(named: "settings.json")
    }()
    
    static private func rootFile(named name: String) -> URL {
        let url = supportPath.appendingPathComponent(name)
        
        if !FileManager.default.fileExists(atPath: url.path) {
            print("Creating \(name)")
            FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
        }
        
        return url
    }
    
    private static var supportPath: URL = {
        // Grab an array of Application Support paths
        let appSupportPaths = NSSearchPathForDirectoriesInDomains(
            .applicationSupportDirectory,
            .userDomainMask,
            true
        )
        
        if appSupportPaths.isEmpty {
            fatalError("FATAL : app support does not exist!")
        }
        
        let appSupportDirectory = URL(fileURLWithPath: appSupportPaths[0], isDirectory: true)
        
        let asFolder = appSupportDirectory.appendingPathComponent("AnimatedScreenSavers")

        if !FileManager.default.fileExists(atPath: asFolder.path) {
            print("Creating app support directory...")
            do {
                try FileManager.default.createDirectory(
                    at: asFolder,
                    withIntermediateDirectories: false,
                    attributes: nil
                )
            } catch let error {
                fatalError("FATAL : Couldn't create app support directory in User directory: \(error)")
            }
        }
        
        return asFolder
    }()
}
