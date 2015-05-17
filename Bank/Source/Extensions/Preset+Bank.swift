//
//  Preset+Bank.swift
//  Remote
//
//  Created by Jason Cardwell on 5/16/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import DataModel

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
