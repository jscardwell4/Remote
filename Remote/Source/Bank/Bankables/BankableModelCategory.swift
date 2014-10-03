//
//  BankableModelCategory.swift
//  Remote
//
//  Created by Jason Cardwell on 10/2/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MoonKit

class BankableModelCategory: NamedModelObject, BankDisplayItemCategory {

  var items: [BankDisplayItemModel] { return [] }
  var subcategories: [BankDisplayItemCategory] { return [] }
  var parentCategory: BankDisplayItemCategory? { return nil }
  
}