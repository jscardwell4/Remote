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

class BankableModelObject: NamedModelObject, BankDisplayItemModel {

	@NSManaged var user: Bool

	override func updateWithData(data: [NSObject : AnyObject]!) {
		super.updateWithData(data)
		user = (data?["user"] as? NSNumber)?.boolValue ?? user
	}

	override func JSONDictionary() -> MSDictionary! {
		let dictionary = super.JSONDictionary()
		setIfNotDefault("user", inDictionary: dictionary)
		dictionary.compact()
		dictionary.compress()
		return dictionary
	}

  var preview:   UIImage? { return nil }
  var thumbnail: UIImage? { return nil }

  class func isPreviewable()   -> Bool { return false }
  class func isEditable()      -> Bool { return false }

  var previewable:   Bool { return self.dynamicType.isPreviewable() }
  var editable:      Bool { return self.dynamicType.isEditable() }

  func detailController() -> UIViewController { return BankItemDetailController(item: self)! }

  func save() {
    managedObjectContext?.performBlockAndWait {
      self.managedObjectContext!.processPendingChanges()
      var error: NSError?
      self.managedObjectContext!.save(&error)
      MSHandleError(error, message: "save failed for '\(self.name)'")
    }
  }

  func delete() { managedObjectContext?.deleteObject(self) }

  func rollback() {
    managedObjectContext?.performBlockAndWait {
      self.managedObjectContext!.processPendingChanges()
      self.managedObjectContext!.rollback()
    }
  }

}
