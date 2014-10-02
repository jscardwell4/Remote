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

	class var isThumbnailable: Bool { return false }
	class var isPreviewable:   Bool { return false }
	class var isDetailable:    Bool { return false }
	class var isEditable:      Bool { return false }
  var uuid: String { return MSNonce() }
  var name: String { return "surrogate" }

	var items: [BankableModelObject] = []

	init(itemType: BankableModelObject.Type) {

		if let fetchedItems = itemType.findAll() as? [BankableModelObject] { items = fetchedItems }

	}

}
