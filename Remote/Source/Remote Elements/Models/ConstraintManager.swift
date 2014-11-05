//
//  ConstraintManager.swift
//  Remote
//
//  Created by Jason Cardwell on 11/4/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MoonKit

extension ConstraintManager {

  var horizontalConstraints: [Constraint] {
    return constraintsAffectingAxis(.Horizontal, order: .FirstOrder)?.allObjects as? [Constraint] ?? []
  }

  var verticalConstraints: [Constraint] {
    return constraintsAffectingAxis(.Vertical, order: .FirstOrder)?.allObjects as? [Constraint] ?? []
  }

}