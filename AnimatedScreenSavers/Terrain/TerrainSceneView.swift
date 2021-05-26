//
//  TerrainSceneView.swift
//  Mesh2
//
//  Created by Liam Rosenfeld on 5/26/21.
//

import SceneKit

class TerrainSceneView: SCNView {
    let terrain = Terrain(width: 2000, depth: 1200, squareSize: 20)
    
    override init(frame: NSRect) {
        super.init(frame: frame, options: nil)
        
        // create view
        self.backgroundColor = NSColor.black
        self.autoenablesDefaultLighting = true
        self.preferredFramesPerSecond = 30
        
        // enable debugging
        #if DEBUG
        self.showsStatistics = true
        #endif
        
        // add terrain
        let scene = SCNScene()
        scene.rootNode.addChildNode(terrain.node)
        
        // add camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zNear = 1
        cameraNode.camera?.zFar  = 1300
        cameraNode.position = SCNVector3(x: CGFloat(terrain.width / 2), y: 300, z: -100)
        cameraNode.rotation = SCNVector4(x: 0, y: 1, z: 1/5, w: .pi)
        cameraNode.name = "camera"
        scene.rootNode.addChildNode(cameraNode)
        
        // add scene to view
        self.scene = scene
        
        // add delegate
        self.delegate = self
        self.isPlaying = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TerrainSceneView: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        terrain.move()
    }
}
