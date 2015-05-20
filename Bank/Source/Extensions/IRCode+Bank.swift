//
//  IRCode+Bank.swift
//  Remote
//
//  Created by Jason Cardwell on 5/16/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import DataModel
import MoonKit
import CoreData

extension IRCode: Detailable {
  func detailController() -> UIViewController { return IRCodeDetailController(model: self) }
}

// TODO: Fill out stubs for `FormCreatable`
extension IRCode: FormCreatable {

  /**
  creationForm:

  :param: #text NSManagedObjectContext

  :returns: Form
  */
  static func creationForm(#context: NSManagedObjectContext) -> Form {
    return Form(templates: [:])
  }

  /**
  createWithForm:context:

  :param: form Form
  :param: context NSManagedObjectContext

  :returns: Self?
  */
  static func createWithForm(form: Form, context: NSManagedObjectContext) -> Self? {
    return nil
  }

}