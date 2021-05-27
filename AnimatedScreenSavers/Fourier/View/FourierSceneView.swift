//
//  ViewController.swift
//  Fourier Artist
//
//  Created by Liam on 2/10/19.
//  Copyright © 2019 Liam Rosenfeld. All rights reserved.
//

import SpriteKit
import Combine

class FourierSceneView: SKView {
    let queue = Queue()
    let fourierScene = FourierScene()
    var sceneSub: AnyCancellable?
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        
        // Set Size
        let sceneSize = CGSize(width: 1800, height: 1200)
        fourierScene.size = sceneSize
        fourierScene.scaleMode = .aspectFit
        
        // Set Properties
        self.preferredFramesPerSecond = 40
        
        // Present
        self.presentScene(fourierScene)
        self.ignoresSiblingOrder = true
        
        queue.loadIn()
        
        fourierScene.epicycles = queue.next()
        
        // Send next path in queue when finished
        sceneSub = fourierScene.finished.sink {
            self.fourierScene.epicycles = self.queue.next()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
