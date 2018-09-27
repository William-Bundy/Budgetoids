//
//  Geom.swift
//  Budgetoids
//
//  Created by William Bundy on 9/26/18.
//  Copyright © 2018 William Bundy. All rights reserved.
//

import Foundation
import SceneKit
import ModelIO
import SceneKit.ModelIO

typealias Vec3 = SCNVector3

extension Vec3 {
	init(_ x:Float, _ y:Float, _ z:Float) {
		self.init(x: x, y: y, z: z)
	}

	init(_ x:Double, _ y:Double, _ z:Double) {
		self.init(x: Float(x), y: Float(y), z: Float(z))
	}

	static func +(l:Vec3, r:Vec3) -> Vec3
	{
		return Vec3(l.x + r.x, l.y + r.y, l.z + r.z)
	}

	static prefix func -(l:Vec3) -> Vec3
	{
		return Vec3(-l.x, -l.y, -l.z)
	}

	static func -(l:Vec3, r:Vec3) -> Vec3
	{
		return l + -r
	}

	static func *(l: Vec3, r:Float) -> Vec3
	{
		return Vec3(l.x * r, l.y * r, l.z * r)
	}

	static func *(r: Float, l:Vec3) -> Vec3
	{
		return Vec3(l.x * r, l.y * r, l.z * r)
	}

	static func *(l: Vec3, rr:Double) -> Vec3
	{
		let r = Float(rr)
		return Vec3(l.x * r, l.y * r, l.z * r)
	}

	static func *(rr: Double, l:Vec3) -> Vec3
	{
		let r = Float(rr)
		return Vec3(l.x * r, l.y * r, l.z * r)
	}
}
