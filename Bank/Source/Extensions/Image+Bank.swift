//
//  Image+Bank.swift
//  Remote
//
//  Created by Jason Cardwell on 5/16/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import DataModel

extension Image: Previewable {}

extension Image: Detailable {
  func detailController() -> UIViewController { return ImageDetailController(model: self) }
}