//
//  ISYDevice+Bank.swift
//  Remote
//
//  Created by Jason Cardwell on 5/16/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import MoonKit
import CoreData
import DataModel

extension ISYDevice: Detailable {
  func detailController() -> UIViewController { return ISYDeviceDetailController(model: self) }
}
