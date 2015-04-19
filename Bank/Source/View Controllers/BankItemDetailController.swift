//
//  BankItemDetailController.swift
//  Remote
//
//  Created by Jason Cardwell on 11/28/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit
import DataModel

class BankItemDetailController: NamedItemDetailController {


  var model: EditableModel! { return item as? EditableModel }
  let context: NSManagedObjectContext!

  /**
  initWithCoder:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { context = nil; super.init(coder: aDecoder) }

  /**
  initWithModel:

  :param: model EditableModel
  */
  init(var model: protocol<EditableModel, Detailable, DynamicallyNamed>) {
    if let dataModel = model as? NamedModelObject {
      context = DataManager.mainContext()
      let objectID = dataModel.objectID
      var error: NSError?
      if let m = context.existingObjectWithID(objectID, error: &error) as? protocol<EditableModel, Detailable, DynamicallyNamed> {
        model = m
      }
    } else {
      context = nil
    }
    super.init(namedItem: model)
  }

}
