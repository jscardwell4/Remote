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

final class BankSurrogateCategory: NSObject, BankModelCollection {

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

extension BankSurrogateCategory: Printable {
  override var description: String {
    var result = "BankSurrogateCategory:\n"
    result += "\tname = \(name)\n"
    result += "\tcollections = "
    if collections.count == 0 { result += "[]\n" }
    else { result += "{\n" + "\n\n".join(collections.map({toString($0)})).indentedBy(8) + "\n\t}\n" }
    result += "\titems = "
    if items.count == 0 { result += "[]\n" }
    else { result += "{\n" + "\n\n".join(items.map({toString($0)})).indentedBy(8) + "\n\t}\n" }
    return result
  }
}