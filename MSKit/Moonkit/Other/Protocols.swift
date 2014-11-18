//
//  Protocols.swift
//  MSKit
//
//  Created by Jason Cardwell on 11/17/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation

public protocol JSONValueConvertible {
  typealias JSONValueType
  var JSONValue: JSONValueType { get }
  init(JSONValue: JSONValueType)
}
