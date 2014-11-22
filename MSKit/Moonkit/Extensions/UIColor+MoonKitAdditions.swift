//
//  UIColor+MoonKitAdditions.swift
//  MoonKit
//
//  Created by Jason Cardwell on 11/21/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit

extension UIColor: JSONValueConvertible {
  typealias JSONValueType = String!
  public var JSONValue: String! { return string }
}
