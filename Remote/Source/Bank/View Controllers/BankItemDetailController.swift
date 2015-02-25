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

class BankItemDetailController: NamedItemDetailController {


  var model: BankDisplayItemModel! { return item as? BankDisplayItemModel }
  let context: NSManagedObjectContext!

  /**
  init:bundle:

  :param: nibNameOrNil String?
  :param: nibBundleOrNil NSBundle?
  */
//  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
//    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//  }

  /**
  initWithStyle:

  :param: style UITableViewStyle
  */
//  override init(style: UITableViewStyle) { super.init(style: style) }

  /**
  initWithCoder:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { context = nil; super.init(coder: aDecoder) }

  /**
  initWithModel:

  :param: model BankableModelObject
  */
  init(model: BankableModelObject) {
    assert(model.managedObjectContext != nil, "initializing controller with deleted model")
    context = DataManager.childContextForContext(model.managedObjectContext!)
    context.nametag = "bank item detail controller"
    let objectID = model.objectID
    var error: NSError?
    let existingObject = context.existingObjectWithID(objectID, error: &error)
    if MSHandleError(error, message: "failed to retrieve existing object by ID") { fatalError("aborting…") }
    super.init(namedItem: existingObject as! BankableModelObject)
  }

}
