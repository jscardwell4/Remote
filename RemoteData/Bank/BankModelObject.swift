//
//  BankModelObject.swift
//  Remote
//
//  Created by Jason Cardwell on 3/20/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc protocol BankModel: NamedModel, Editable {
  var user: Bool { get }
}

class BankModelObject: NamedModelObject, BankModel {
  @NSManaged var user: Bool

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

  :returns: MSDictionary
  */
  override func JSONDictionary() -> MSDictionary {
    let dictionary = super.JSONDictionary()

    appendValueForKey("user", toDictionary: dictionary)

    dictionary.compact()
    dictionary.compress()
    
    return dictionary
  }

}

typealias IndexedBankModel = protocol<BankModel, Indexed>

class IndexedBankModelObject: BankModelObject, IndexedBankModel {
  var index: String { return name }
}
