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
import ModelIO

// WHY
import SceneKit.ModelIO




class GameVC:UIViewController
{
	@IBOutlet weak var gameView: GameSceneView!

	@IBOutlet weak var debugLabel: UILabel!
	override func viewDidLoad()
	{
		guard let gameView = gameView else { NSLog("Could not load gameView"); return }
		guard let scene = SCNScene(named: "SceneAssets.scnassets/emptyScene.scn") else { NSLog("Could not load scene"); return }
		gameView.debugLabel = debugLabel
		gameView.scene = scene
		gameView.rendersContinuously = true
		//gameView.allowsCameraControl = true
		gameView.autoenablesDefaultLighting = true

		let skybox = MDLTexture(cubeWithImagesNamed: (1...6).map({"SceneAssets.scnassets/Textures/Skybox/\($0).png"}), bundle: nil)

		gameView.scene?.background.contents = skybox

		gameView.gameInit()
	}

	override func viewDidAppear(_ animated: Bool)
	{
		super.viewDidAppear(animated)

		gameView.gameStart()
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		gameView.gamePause()
	}
}

func rng() -> Double
{
	var g = SystemRandomNumberGenerator()
	// not technically accurate
	return Double(g.next()) / Double(UINT64_MAX)
}

func rng(_ min:Double, _ max:Double) -> Double
{
	return rng() * (max - min) + min
}

func rng(_ min:Int, _ max:Int) -> Double
{
	return rng(Double(min), Double(max))
}


class GameSceneView:SCNView, SCNSceneRendererDelegate
{
	// this is totally flash
	var debugLabel:UILabel!
	var root:SCNNode!
	var camera:SCNNode!
	var ship:SCNNode!

	var vel:Vec3 = Vec3(0, 0, 0)
	var cameraOffset:Vec3 = Vec3(0, -200, -100)
	var cameraPosition:Vec3 = Vec3(0, 0, 0)

	var mouse:Vec3?
	var savedTouch:UITouch?

	func gameInit()
	{
		self.delegate = self
		root = scene?.rootNode

		camera = root.childNode(withName: "camera", recursively: false)
		if camera == nil {
			NSLog("Could not find camera in scene")
		}

		let shipURL = Bundle.main.url(forResource: "spaceCraft1", withExtension: "obj", subdirectory: "SceneAssets.scnassets/obj")
		guard let url = shipURL else { return }
		let asset = MDLAsset(url: url)
		guard let mesh = asset[0] as? MDLMesh else { NSLog("Cannot get mesh"); return }
		let shipGeom = SCNGeometry(mdlMesh:mesh)
		ship = SCNNode(geometry: shipGeom)
		//ship.position = Vec3(10, 10, 10)
		camera.position = ship.position - cameraOffset
		camera.look(at: ship.position)
		root.addChildNode(ship)

		vel.z = 50
		vel.x = -20


		for _ in 0...500 {
			let deadShip = SCNNode(geometry: shipGeom)
			deadShip.position = Vec3(
				rng(-500, 500),
				rng(-50,  -200),
				rng(-500, 500))

			deadShip.eulerAngles = Vec3(
				rng(-Double.pi, Double.pi),
				rng(-Double.pi, Double.pi),
				rng(-Double.pi, Double.pi))

			root.addChildNode(deadShip)
		}
	}

	func gameStart()
	{

	}

	// "gameUpdate"
	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)
	{
		ship.position = ship.position + vel * (1.0 / 60.0)
		vel = vel * 0.99
		if vel.x * vel.x + vel.z * vel.z < 1 {
			vel = Vec3(0, 0, 0)
		}


		var cameraVel:Vec3 = ((ship.position - cameraPosition) * (1.0 / 4.0))
		cameraVel.y = 0

		cameraPosition = cameraPosition + cameraVel
		camera.position = cameraPosition - cameraOffset

		setDebugText("\(vel), \(sqrtf(vel.x * vel.x + vel.z * vel.z))")
		if let mouse = mouse {
			let angle = atan2(mouse.z, mouse.x)
			ship.eulerAngles.y = -angle - Float.pi / 2
			let move:Float = 10.0
			vel = vel + Vec3(cos(angle) * move, 0, sin(angle) * move)
			var vel2 = vel.x * vel.x + vel.z * vel.z
			let maxSpeed:Float = 200.0
			if vel2 > (maxSpeed * maxSpeed) {
				vel2 = sqrtf(vel2)
				let angle = atan2(vel.z, vel.x)
				vel.x = cos(angle) * maxSpeed
				vel.z = sin(angle) * maxSpeed
			}
			vel.y = 0
		}
	}

	func gamePause()
	{

	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first else { mouse = nil; return }
		if savedTouch != nil {
			return
		} else {
			savedTouch = touch
		}
		let loc = touch.location(in: self)
		let f = Vec3(frame.width, 0, frame.height) * 0.5
		let vec = Vec3(loc.x, 0, loc.y) - f
		mouse = vec// + cameraPosition//self.projectPoint(vec) - cameraOffset
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		var localTouches = touches
		guard var savedTouch = self.savedTouch else { return }
		if touches.contains(savedTouch) {
			self.savedTouch = localTouches.remove(savedTouch)
			guard let st2 = self.savedTouch else { return }
			savedTouch = st2
			let loc = savedTouch.location(in: self)
			let f = Vec3(frame.width, 0, frame.height) * 0.5
			let vec = Vec3(loc.x, 0, loc.y) - f
			mouse = vec// + cameraPosition//self.projectPoint(vec) - cameraOffset
		}
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let savedTouch = self.savedTouch else { return }
		if touches.contains(savedTouch) {
			self.savedTouch = nil
			mouse = nil
		}
	}

	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let savedTouch = self.savedTouch else { return }
		if touches.contains(savedTouch) {
			self.savedTouch = nil
			mouse = nil
		}
	}


	func setDebugText(_ s:String)
	{
		if let l = debugLabel {
			DispatchQueue.main.async {
				l.text = s
			}
		}
	}
}



