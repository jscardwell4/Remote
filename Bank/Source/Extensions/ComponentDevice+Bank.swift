//
//  ComponentDevice+Bank.swift
//  Remote
//
//  Created by Jason Cardwell on 5/16/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import DataModel

extension ComponentDevice: Detailable {
  func detailController() -> UIViewController { return ComponentDeviceDetailController(model: self) }
}