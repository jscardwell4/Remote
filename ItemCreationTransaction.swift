//
//  ItemCreationTransaction.swift
//  Remote
//
//  Created by Jason Cardwell on 7/20/15.
//  Copyright © 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import MoonKit
import DataModel

struct CustomTransaction: ItemCreationTransaction {
  typealias CustomController = (didCancel: () -> Void, didCreate: (ModelObject) -> Void) -> UIViewController

  let label: String
  let controller: CustomController
}

struct FormTransaction: ItemCreationTransaction {
  let label: String
  let form: Form
  let processedForm: ProcessedForm
}

struct DiscoveryTransaction: ItemCreationTransaction {
  let label: String
  let beginDiscovery: ((Form, ProcessedForm) -> Void) -> Void
  let endDiscovery: () -> Void
}
