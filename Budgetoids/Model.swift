//
//  Model.swift
//  Budgetoids
//
//  Created by William Bundy on 9/24/18.
//  Copyright © 2018 William Bundy. All rights reserved.
//

import Foundation
import CoreData

// Txn == Transaction
enum TxnCategory:String
{
	case regular
	case misc
	case urgent

	static let all:[TxnCategory] = [.regular, .misc, .urgent]
	static let dict:[String:TxnCategory] = [
		TxnCategory.regular.rawValue:TxnCategory.regular,
		TxnCategory.urgent.rawValue:TxnCategory.urgent,
		TxnCategory.misc.rawValue:TxnCategory.misc
	]

}

extension BudgetMonth
{
	convenience init(_ startDate:Date, _ endDate:Date, moc:MOContext=DataStack.moc)
	{
		self.init(context: moc)
		self.startDate = startDate
		self.endDate = endDate
	}
}

extension TxnGroup
{
	convenience init(_ name:String, _ shortName:String? = nil, moc:MOContext=DataStack.moc)
	{
		self.init(context: moc)
		self.name = name
		self.shortName = shortName ?? name
	}

	func getStub() -> GroupStub
	{
		return GroupStub(
    			name: self.name ?? "???",
    			shortName: self.shortName ?? "?")
	}
}

struct GroupStub:Hashable, Comparable
{
	var name:String
	var shortName:String

	static func <(l:GroupStub, r:GroupStub) -> Bool
	{
		return l.name < r.name
	}
}

extension TxnLocation
{
	convenience init(_ name:String, moc:MOContext=DataStack.moc)
	{
		self.init(context: moc)
		self.name = name
	}

	func getStub() -> LocationStub
	{
		return LocationStub(name: self.name ?? "Unknown")
	}
}

struct LocationStub:Hashable, Comparable
{
	var name:String

	static func <(l:LocationStub, r:LocationStub) -> Bool
	{
		return l.name < r.name
	}

}

extension Transaction
{
	convenience init(
			_ amount:Int,
			_ category:String = TxnCategory.regular.rawValue,
			_ timestamp:Date = Date(),
			_ uuid:UUID = UUID(),

			_ group:TxnGroup? = nil,
			_ location:TxnLocation? = nil,

			moc:MOContext = DataStack.moc)
	{
		self.init(context: moc)
		self.amount = Int32(amount)
		self.category = category
		self.timestamp = timestamp
		self.identifier = uuid

		self.group = group
		self.location = location
	}

	func applyStub(_ stub:TxnStub)
	{
		self.amount = Int32(stub.amount)
		self.category = stub.category.rawValue
		self.timestamp = stub.timestamp
		self.identifier = stub.identifier

		let controller = TransactionController.shared
		self.group = stub.group != nil ? controller.groups[stub.group!] : nil
		self.location = stub.location != nil ? controller.locations[stub.location!] : nil
	}

	func getStub() -> TxnStub
	{
		let uuid:UUID = self.identifier ?? UUID()
		self.identifier = uuid
		return TxnStub(
			Int(self.amount),
			TxnCategory.dict[self.category ?? "regular"] ?? .regular,
			self.timestamp ?? Date(),
			uuid,
			self.group?.getStub(),
			self.location?.getStub())
	}
}

struct TxnStub: Equatable, Comparable
{
	var amount:Int
	var category:TxnCategory
	var timestamp:Date
	var identifier:UUID

	var location:LocationStub?
	var group:GroupStub?

	static func <(l:TxnStub, r:TxnStub) -> Bool
	{
		return l.timestamp < r.timestamp
	}

	static func ==(l:TxnStub, r:TxnStub) -> Bool
	{
		return l.identifier == r.identifier
	}

	init(
    		_ amount:Int,
    		_ category:TxnCategory = .regular,
    		_ timestamp:Date = Date(),
			_ uuid:UUID = UUID(),
			_ group:GroupStub? = nil,
			_ location:LocationStub? = nil)
	{
		self.amount = amount
		self.category = category
		self.timestamp = timestamp
		self.identifier = uuid
		self.group = group
		self.location = location
	}
}

class TransactionController
{
	static var shared = TransactionController()

	var transactions:[TxnStub] = []
	var groups:[GroupStub:TxnGroup] = [:]
	var locations:[LocationStub:TxnLocation] = [:]

	func add(_ transaction:TxnStub)
	{
		transactions.append(transaction)
	}

	func update(_ transaction:TxnStub, with replacement:TxnStub)
	{
		if let index = transactions.index(of:transaction) {
			transactions[index] = replacement
		}
	}

	func remove(_ transaction:TxnStub)
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

