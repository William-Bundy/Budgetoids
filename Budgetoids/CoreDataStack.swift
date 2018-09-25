//
//  CoreDataStack.swift
//  Budgetoids
//
//  Created by William Bundy on 9/24/18.
//  Copyright © 2018 William Bundy. All rights reserved.
//

import Foundation
import CoreData

typealias MOContext = NSManagedObjectContext

class DataStack
{
	static var shared = DataStack()
	static var moc:MOContext { return DataStack.shared.container.viewContext }

	lazy var container:NSPersistentContainer = {
		var con = NSPersistentContainer(name: "Budgetoids")
		con.loadPersistentStores { _, error in
			if let error = error {
				NSLog("Error loading persistent stores: \(error)")
				fatalError()
			}
		}
		con.viewContext.automaticallyMergesChangesFromParent = true

		return con
	}()

	var mainContext:MOContext { return container.viewContext }
}

extension MOContext {

	@discardableResult
	func safeSave(withReset:Bool = true) -> Bool
	{
		var didSave = true
		self.performAndWait {
			do {
				try self.save()
			} catch {
				NSLog("Failed to save moc: \(error)")
				if withReset {
					self.reset()
				}
				didSave = false
			}
		}
		return didSave
	}
}
