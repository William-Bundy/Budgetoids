//
//  Views.swift
//  Budgetoids
//
//  Created by William Bundy on 9/20/18.
//  Copyright © 2018 William Bundy. All rights reserved.
//

import Foundation
import UIKit

class TransactionCell:UITableViewCell
{
	@IBOutlet weak var amountLabel: UILabel!
	var transaction:TxnStub! {
		didSet {
			amountLabel.setMoney(transaction.amount)
		}
	}
}

class TransactionTVC:UITableViewController
{
	var controller:TransactionController!
	var weeklyMoney = 100_00

	@IBOutlet weak var amountField: UITextField!
	@IBOutlet weak var prioritySelector: UISegmentedControl!

	override func viewDidLoad()
	{
		controller = TransactionController.shared
		amountField.keyboardType = .numberPad
	}

	@IBAction func amountChanged(_ sender: Any)
	{
		amountField.setMoney(amountField.getMoneyAsInt())
	}

	@IBAction func addTransaction(_ sender: Any)
	{
		guard let money = amountField.getMoneyAsInt() else { return }

		if let sender = sender as? UITextField {
			sender.resignFirstResponder()
		}

		let category = TxnCategory.all[prioritySelector.selectedSegmentIndex]
		let txn = TxnStub(money, category)

		amountField.text = nil

		controller.add(txn)
		setTitleToRemainingMoney()
		tableView.reloadData()
	}

	func setTitleToRemainingMoney()
	{
		var moneySpent = 0
		for txn in controller.transactions {
			moneySpent += txn.amount
		}

		navigationItem.title = String.fromMoney(weeklyMoney - moneySpent)
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return controller.transactions.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let defaultCell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath)
		guard let cell = defaultCell as? TransactionCell else { return defaultCell }
		cell.transaction = controller.transactions[indexPath.row]
		return cell
	}

	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			controller.removeAt(indexPath.row)
			tableView.deleteRows(at: [indexPath], with: .left)
		}
	}
}

extension UILabel
{
	func setMoney(_ v:Int?, _ fmt:String="%@")
	{
		guard let v = v else {return}

		let f = NumberFormatter()
		f.numberStyle = .currency
		if let m = f.string(from: NSNumber(value: Double(v) / 100.0)) {
			self.text = String(format: fmt, m)
		}
	}
}

extension String
{
	static func fromMoney(_ v:Int?) -> String?
	{
		guard let v = v else {return nil}

		let f = NumberFormatter()
		f.numberStyle = .currency
		if let m = f.string(from: NSNumber(value: Double(v) / 100.0)) {
			return m
		}
		return nil
	}

	static func toMoney(_ text:String) -> Int?
	{
		let numbers = text.filter { "0123456789".contains($0) }
		return Int(numbers)
	}
}

extension UITextField
{
	func setMoney(_ v:Int?)
	{
		guard let v = v else {return}

		let f = NumberFormatter()
		f.numberStyle = .currency
		if let m = f.string(from: NSNumber(value: Double(v) / 100.0)) {
			self.text = m
		}
	}

	func getMoneyAsInt() -> Int?
	{
		let text = self.text ?? ""
		let numbers = text.filter { "0123456789".contains($0) }
		return Int(numbers)
	}
}

