//
//  BankableModelObject.swift
//  Remote
//
//  Created by Jason Cardwell on 10/2/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(BankableModelObject)
class BankableModelObject: NamedModelObject, BankModel {

	@NSManaged var user: Bool

  /**
  requiresUniqueNaming

  :returns: Bool
  */
  override class func requiresUniqueNaming() -> Bool { return true }

	/**
	updateWithData:

	:param: data [String:AnyObject]
	*/
	override func updateWithData(data: [String:AnyObject]) {
		super.updateWithData(data)
    if let user = data["user"] as? NSNumber { self.user = user.boolValue }
	}

	/**
	JSONDictionary

	:returns: MSDictionary!
	*/
	override func JSONDictionary() -> MSDictionary {
		let dictionary = super.JSONDictionary()
		setIfNotDefault("user", inDictionary: dictionary)
		dictionary.compact()
		dictionary.compress()
		return dictionary
	}

  var editable: Bool { return user }

  /**
  detailController

  :returns: UIViewController
  */
  func detailController() -> UIViewController { return BankItemDetailController(model: self) }

}
