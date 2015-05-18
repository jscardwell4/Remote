//
//  Preset+Bank.swift
//  Remote
//
//  Created by Jason Cardwell on 5/16/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import DataModel
import CoreData
import MoonKit

extension Preset: Previewable {}

extension Preset: Detailable {
  func detailController() -> UIViewController {
    switch baseType {
      case .Remote:      return RemotePresetDetailController(model: self)
      case .ButtonGroup: return ButtonGroupPresetDetailController(model: self)
      case .Button:      return ButtonPresetDetailController(model: self)
      default:           return PresetDetailController(model: self)
    }
  }
}

extension Preset: FormCreatable {
  static func formFields(#context: NSManagedObjectContext) -> FormViewController.FieldCollection {
    return ["Name":FormViewController.Field.Text(value: "", placeholder: "The manufacturer's name") {
      $0 != nil && !$0!.isEmpty && Preset.objectWithValue($0!, forAttribute: "name", context: context) == nil
      }]
  }
  static func createWithFormValues(values: FormViewController.FieldValues, context: NSManagedObjectContext) -> Preset? {
    if let name = values["Name"] as? String {
      let preset = Preset(context: context)
      preset.name = name
      return preset
    } else {
      return nil
    }
  }
}