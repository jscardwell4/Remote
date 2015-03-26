//
//  CommandContainer.swift
//  Remote
//
//  Created by Jason Cardwell on 3/2/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import Foundation
import CoreData
import MoonKit

@objc(CommandContainer)
public class CommandContainer: NamedModelObject {

  @NSManaged public var containerIndex: MSDictionary
  @NSManaged public var buttonGroup: ButtonGroup?

  public var count: Int { return containerIndex.count }

}