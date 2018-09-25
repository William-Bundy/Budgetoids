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

class CoreDataStack
{
	static var shared = CoreDataStack()

	lazy var container:NSPersistentContainer = {
		var con = NSPersistentContainer(name: "Budgetoids")

		con.loadPersistentStores(completionHandler: <#T##(NSPersistentStoreDescription, Error?) -> Void#>)

		return con
	}()

	var mainContext:MOContext { return container.viewContext }
}
