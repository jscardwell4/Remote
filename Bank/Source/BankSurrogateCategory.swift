//
//  BankSurrogateCategory.swift
//  Remote
//
//  Created by Jason Cardwell on 10/2/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit
import DataModel

class BankSurrogateCategory: NSObject, BankModelCollection {

  var collections: [ModelCollection] = []
  var items: [NamedModel] = []
  var name: String

  /**
  initWithTitle:collections:items:

  :param: title String
  :param: collections [ModelCollection] = []
  :param: items [NamedModel] = []
  */
  init(title: String,
       collections: [ModelCollection] = [],
       items: [NamedModel] = [])
  {
    self.name = title
    self.collections = collections
    self.items = items
  }

}