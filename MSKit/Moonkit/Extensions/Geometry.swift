//
//  Geometry.swift
//  MSKit
//
//  Created by Jason Cardwell on 10/26/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation

extension CGSize {
  public init(square: CGFloat) { self = CGSize(width: square, height: square) }
}

extension CGRect {
  public init(size: CGSize) { self = CGRect(x: 0, y: 0, width: size.width, height: size.height) }
//  public init(origin: CGPoint, size: CGSize) { self = CGRect(x: origin.x, y: origin.y, width: size.width, height: size.height) }
}