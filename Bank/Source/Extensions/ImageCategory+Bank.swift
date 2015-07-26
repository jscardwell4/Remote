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
  var itemLabel: String { return "Image" }
  var collectionLabel: String { return "Category" }
}


extension ImageCategory: FormCreatable {
  /**
  creationForm:

  - parameter #context: NSManagedObjectContext

  - returns: Form
  */
  static func creationForm(context context: NSManagedObjectContext) -> Form {
    return Form(templates: OrderedDictionary<String, FieldTemplate>(["Name": nameFormFieldTemplate(context: context)]))
  }

  /**
  createWithForm:context:

  - parameter form: Form
  - parameter context: NSManagedObjectContext

  - returns: ImageCategory?
  */
  static func createWithForm(form: Form, context: NSManagedObjectContext) -> ImageCategory? {
    if let name = form.values?["Name"] as? String { return ImageCategory(name: name, context: context) } else { return nil }
  }
}

extension ImageCategory: CustomCreatableItem {
  func itemCreationControllerWithContext(context: NSManagedObjectContext,
                     cancellationHandler didCancel: () -> Void,
                         creationHandler didCreate: (ModelObject) -> Void) -> UIViewController
  {
    return Image.creationControllerWithContext(context,
                           cancellationHandler: didCancel) {($0 as! Image).imageCategory = self; didCreate($0) }
  }
}

extension ImageCategory: FormCreatableCollection {
  func collectionCreationForm(context context: NSManagedObjectContext) -> Form { return ImageCategory.creationForm(context: context) }
  func createCollectionWithForm(form: Form, context: NSManagedObjectContext) -> Bool {
    var success = false
    context.performBlockAndWait {
      if let category = ImageCategory.createWithForm(form, context: context) {
        category.parentCategory = self
        success = true
      }
    }
    return success
  }
}