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

class BankModelObject: NamedModelObject, BankModel {
  @NSManaged var user: Bool
}

//class IndexedBankModelObject: BankModelObject, IndexedBankModel {
//  var index: String { return name }
//}
