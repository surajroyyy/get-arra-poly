//
//  ViewController.swift
//  ArraPolyViewTest
//
//  Created by Suraj Roy on 6/13/18.
//  Copyright © 2018 Suraj Roy. All rights reserved.
//

import UIKit
import SceneKit
import ModelIO
import SceneKit.ModelIO
import ARKit
import Disk
import Alamofire
import MZFormSheetPresentationController
import Darwin

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    let modelsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    var urlT: String = "https://poly.googleapis.com/downloads/bTcqWpYqeeM/5ZguYRZzRq5/car_02.obj"
    var name: String = "Car_02"
    var count: Int = 0
    
    var oldName: String?
    
    var textT: String = "https://poly.googleapis.com/downloads/bTcqWpYqeeM/5ZguYRZzRq5/car_02.mtl"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = ARSCNDebugOptions.showWorldOrigin
        
        displayObject()
        
       
    }
    
    func formSheetControllerWithNavigationController() -> UINavigationController {
        return self.storyboard!.instantiateViewController(withIdentifier: "formSheetController") as! UINavigationController
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "segue" {
                let presentationSegue = segue as! MZFormSheetPresentationViewControllerSegue
                presentationSegue.formSheetPresentationController.presentationController?.shouldApplyBackgroundBlurEffect = true
                let navigationController = presentationSegue.formSheetPresentationController.contentViewController as! UINavigationController
                let presentedViewController = navigationController.viewControllers.first as! ThumbnailViewController
                presentedViewController.completion = { name, url in
                    self.name = name
                    self.urlT = url
                    self.removeNode()
                    self.displayObject()
                }
                presentationSegue.formSheetPresentationController.presentationController?.contentViewSize = CGSize(width: 350, height: 350)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
        
    
        
    }
    
    func removeNode() {
        
        sceneView.scene.rootNode.childNode(withName: oldName!, recursively: true)?.removeFromParentNode()
        print("Removed child node!")
    }
    
    func displayObject() {

        
        let url = URL(string: urlT)!
        let textureURL = URL(string: textT)!
        
        print (urlT)
        print (name)
        print(textT)
        
//        if Disk.exists("Car_02.obj", in: .caches) {
//            print("true")
//        }
        
        do {
            let modelData = try Data(contentsOf: url as URL, options: [])
            try Disk.save(modelData, to: .caches, as: "objectData/\(name).obj")
            let modelURL = try Disk.getURL(for: "objectData/\(name).obj", in: .caches)
            
            let textureData = try Data(contentsOf: textureURL, options: [])
            try Disk.save(textureData, to: .caches, as: "objectData/\(name).mtl")
            
            if Disk.exists("objectData", in: .caches){
                print(true)
            }
            
            let asset = MDLAsset(url: modelURL)
            asset.loadTextures()
            let object = asset.object(at: 0)

            let node = SCNNode(mdlObject: object)
            node.scale = SCNVector3(0.001, 0.001, 0.001)
            node.position = SCNVector3Make(0, -0.2, -0.8)
            node.name = "\(name)"
            oldName = "\(name)"
            sceneView.scene.rootNode.addChildNode(node)
        
           // try Disk.clear(.caches)
            
        }
        catch {
            
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}


