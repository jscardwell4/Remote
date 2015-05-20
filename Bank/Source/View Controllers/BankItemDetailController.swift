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
  let context: NSManagedObjectContext

//  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
//    context = NSManagedObjectContext()
//    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//  }

  /**
  initWithCoder:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { fatalError("must use init(model:") }

  /**
  initWithModel:

  :param: model EditableModel
  */
  init(model: protocol<EditableModel, Detailable, DynamicallyNamed>) {
    assert(model.managedObjectContext?.concurrencyType == .MainQueueConcurrencyType)
    context = model.managedObjectContext!
//    if let dataModel = model as? NamedModelObject {
//      context = DataManager.mainContext()
//      let objectID = dataModel.objectID
//      var error: NSError?
//      if let m = context.existingObjectWithID(objectID, error: &error) as? protocol<EditableModel, Detailable, DynamicallyNamed> {
//        model = m
//      }
//    } else {
//      context = nil
//    }
    super.init(namedItem: model)
  }

}
