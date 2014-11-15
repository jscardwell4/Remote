//
//  RemoteElement.swift
//  Remote
//
//  Created by Jason Cardwell on 11/14/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

extension RemoteElement {

  var firstOrderConstraints: [Constraint] { return firstItemConstraints.allObjects as [Constraint] }
  var secondOrderConstraints: [Constraint] { return secondItemConstraints.allObjects as [Constraint] }
  var ownedConstraints: [Constraint] { return constraints.allObjects as [Constraint] }

}
