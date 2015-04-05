//
//  NSNumber+MoonKitAdditions.swift
//  MoonKit
//
//  Created by Jason Cardwell on 4/5/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation

extension NSNumber: JSONValueConvertible {
  public var jsonValue: JSONValue { return .Number(self) }
}