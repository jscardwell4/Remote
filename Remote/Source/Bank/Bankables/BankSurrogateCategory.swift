//
//  BankSurrogateCategory.swift
//  Remote
//
//  Created by Jason Cardwell on 10/2/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import MoonKit

@objc(BankSurrogateCategory)
class BankSurrogateCategory: NSObject, BankDisplayItemCategory {

	class func isThumbnailable() -> Bool { return false }
	class func isPreviewable()   -> Bool { return false }
	class func isDetailable()    -> Bool { return false }
	class func isEditable()      -> Bool { return false }

  var uuid: String { return MSNonce() }
  var name: String { return "surrogate" }
  var subcategories: [BankDisplayItemCategory] { return [] }
  var parentCategory: BankDisplayItemCategory? { return nil }

  typealias ItemType = BankableModelObject

	var items: [ItemType] = []

	init(itemType: BankableModelObject.Type) {

		if let fetchedItems = itemType.findAll() as? [BankableModelObject] { items = fetchedItems }

	}

}
