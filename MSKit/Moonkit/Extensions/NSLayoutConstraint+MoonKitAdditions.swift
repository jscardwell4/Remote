//
//  NSLayoutConstraint+MoonKitAdditions.swift
//  MSKit
//
//  Created by Jason Cardwell on 10/7/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

public func createIdentifier(object: Any, _ suffix: String? = nil) -> String {
  return createIdentifier(object, suffix == nil ? nil : [suffix!])
}

public func createIdentifier(object: Any, _ suffix: [String]? = nil) -> String {
  let identifier = _stdlib_getDemangledTypeName(object)
  return suffix == nil ? identifier : "-".join([identifier] + suffix!)
}
