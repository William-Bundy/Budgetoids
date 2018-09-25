//
//  Model.swift
//  Budgetoids
//
//  Created by William Bundy on 9/24/18.
//  Copyright © 2018 William Bundy. All rights reserved.
//

import Foundation
import CoreData

enum TransactionCategory:String
{
	case regular
	case misc
	case urgent

	static let all:[TransactionCategory] = [.regular, .misc, .urgent]
}

extension TxnGroup
{
	convenience init()
	{
		self.init(context: CoreDataStack.shared.mainContext)
	}
}

extension TxnLocation
{
	convenience init()
	{
		self.init(context: CoreDataStack.shared.mainContext)
	}
}

extension Transaction
{
	convenience init(
			_ amount:Int,
			moc:MOContext = CoreDataStack.shared.mainContext)
	{
		self.init(context: moc)
	}
}

struct TransactionStub: Equatable, Comparable
{
	var amount:Int
	var category:TransactionCategory
	var timestamp:Date
	var identifier:UUID
	

	static func <(l:TransactionStub, r:TransactionStub) -> Bool
	{
		return l.timestamp < r.timestamp
	}

	static func ==(l:TransactionStub, r:TransactionStub) -> Bool
	{
		return l.identifier == r.identifier
	}

	init(_ amount:Int, _ category:TransactionCategory = .regular,
		 _ timestamp:Date = Date(),
		 _ uuid:UUID = UUID())
	{
		self.amount = amount
		self.category = category
		self.timestamp = timestamp
		self.identifier = uuid
	}
}

class TransactionController
{
	static var shared = TransactionController()

	var transactions:[TransactionStub] = []

	func add(_ transaction:TransactionStub)
	{
		transactions.append(transaction)
	}

	func update(_ transaction:TransactionStub, with replacement:TransactionStub)
	{
		if let index = transactions.index(of:transaction) {
			transactions[index] = replacement
		}
	}

	func remove(_ transaction:TransactionStub)
	{
		if let index = transactions.index(of:transaction) {
			transactions.remove(at: index)
		}
	}
	func removeAt(_ index:Int)
	{
		if index >= 0 && index < transactions.count {
			transactions.remove(at: index)
		}
	}
}

