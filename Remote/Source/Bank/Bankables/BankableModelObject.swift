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

class BankableModelObject: NamedModelObject {

	@NSManaged var user: Bool

	override func updateWithData(data: [NSObject : AnyObject]!) {
		super.updateWithData(data)
		name = data?["name"] as? NSString ?? name
		user = (data?["user"] as? NSNumber)?.boolValue ?? user
	}

	override func JSONDictionary() -> MSDictionary! {
		let dictionary = super.JSONDictionary()
		setIfNotDefault("name", inDictionary: dictionary)
		setIfNotDefault("user", inDictionary: dictionary)
		dictionary.compact()
		dictionary.compress()
		return dictionary
	}

  class func categoryType() -> BankDisplayItemCategory.Protocol { return BankSurrogateCategory.self }


}

extension BankableModelObject: BankDisplayItem {

  class func isThumbnailable() -> Bool { return false }
  class func isPreviewable()   -> Bool { return false }
  class func isDetailable()    -> Bool { return false }
  class func isEditable()      -> Bool { return false }

  class func label() -> String? { return nil }
  class func icon() -> UIImage? { return nil }
}

extension BankableModelObject: BankDisplayItemModel {

  typealias DetailControllerType = BankItemDetailController


  var preview:   UIImage? { return nil }
  var thumbnail: UIImage? { return nil }

  

  var detailController: DetailControllerType? { return nil }
  var editingController: DetailControllerType? { return nil }

}
