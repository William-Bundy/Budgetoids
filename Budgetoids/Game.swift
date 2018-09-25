//
//  Game.swift
//  Budgetoids
//
//  Created by William Bundy on 9/20/18.
//  Copyright © 2018 William Bundy. All rights reserved.
//

import Foundation
import UIKit
import SceneKit


class GameVC:UIViewController
{
	@IBOutlet weak var gameView: GameSceneView!

	override func viewDidLoad()
	{
		guard let scene = SCNScene(named: "scene0.scn") else { NSLog("Failed to load scene"); return }
		gameView.scene = scene
		gameView.rendersContinuously = true
		gameView.allowsCameraControl = true

	}

	override func viewDidAppear(_ animated: Bool)
	{
		super.viewDidAppear(animated)
	}
}

class GameSceneView:SCNView
{
	
}
