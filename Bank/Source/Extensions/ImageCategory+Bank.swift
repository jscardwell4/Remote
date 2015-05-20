//
//  ImageCategory+Bank.swift
//  Remote
//
//  Created by Jason Cardwell on 5/16/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import DataModel
import MoonKit
import CoreData

extension ImageCategory: BankModelCollection {
  var itemType: CollectedModel.Type { return Image.self }
  var collectionType: ModelCollection.Type { return ImageCategory.self }
  var previewable: Bool { return true }
}


extension ImageCategory: FormCreatable {
  /**
  creationForm:

  :param: #context NSManagedObjectContext

  :returns: Form
  */
  static func creationForm(#context: NSManagedObjectContext) -> Form {
    return Form(templates: OrderedDictionary<String, FieldTemplate>(["Name": nameFormFieldTemplate(context: context)]))
  }

  /**
  createWithForm:context:

  :param: form Form
  :param: context NSManagedObjectContext

  :returns: ImageCategory?
  */
  static func createWithForm(form: Form, context: NSManagedObjectContext) -> ImageCategory? {
    if let name = form.values?["Name"] as? String { return ImageCategory(name: name, context: context) } else { return nil }
  }
}