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

class BankItemDetailController: DetailController {


  var model: BankDisplayItemModel! { return item as? BankDisplayItemModel }
  let context: NSManagedObjectContext!

  /**
  init:bundle:

  :param: nibNameOrNil String?
  :param: nibBundleOrNil NSBundle?
  */
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  /**
  initWithStyle:

  :param: style UITableViewStyle
  */
  override init(style: UITableViewStyle) { super.init(style: style) }

  /**
  initWithCoder:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /**
  initWithModel:

  :param: model BankableModelObject
  */
  init(model: BankableModelObject) {
    assert(model.managedObjectContext != nil, "initializing controller with deleted model")
    context = CoreDataManager.childContextOfType(.MainQueueConcurrencyType, forContext: model.managedObjectContext!)
    let objectID = model.objectID
    let item = context.existingObjectWithID(objectID, error: nil) as BankableModelObject
    super.init(item: item)
  }

}
