//
//  Geometry.swift
//  MSKit
//
//  Created by Jason Cardwell on 10/26/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

extension CGPoint {
	public func xDelta(point: CGPoint) -> CGFloat { return x - point.x }
	public func yDelta(point: CGPoint) -> CGFloat { return y - point.y }
	public func delta(point: CGPoint) -> CGPoint { return CGPoint(x: xDelta(point), y: yDelta(point)) }
	public func absXDelta(point: CGPoint) -> CGFloat { return abs(x - point.x) }
	public func absYDelta(point: CGPoint) -> CGFloat { return abs(y - point.y) }
	public func absDelta(point: CGPoint) -> CGPoint { return CGPoint(x: absXDelta(point), y: absYDelta(point)) }
}

public func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint { return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y) }

extension CGSize {
  public init(square: CGFloat) { self = CGSize(width: square, height: square) }
  public func contains(size: CGSize) -> Bool { return width >= size.width && height >= size.height }
  public var minAxis: CGFloat { return min(width, height) }
  public var maxAxis: CGFloat { return max(width, height) }
  public var area: CGFloat { return width * height }
  public var integralSize: CGSize { return CGSize(width: round(width), height: round(height)) }
  public var integralSizeRoundingUp: CGSize {
  	var size = CGSize(width: round(width), height: round(height))
  	if size.width < width { size.width += CGFloat(1) }
  	if size.height < height { size.height += CGFloat(1) }
  	return size
  }
  public var integralSizeRoundingDown: CGSize {
  	var size = CGSize(width: round(width), height: round(height))
  	if size.width > width { size.width -= CGFloat(1) }
  	if size.height > height { size.height -= CGFloat(1) }
  	return size
  }

  public func aspectMappedToWidth(w: CGFloat) -> CGSize { return CGSize(width: w, height: (w * height) / width) }
  public func aspectMappedToHeight(h: CGFloat) -> CGSize { return CGSize(width: (h * width) / height, height: h) }
  public func aspectMappedToSize(size: CGSize, binding: Bool = false) -> CGSize {
  	let widthMapped = aspectMappedToWidth(size.width)
  	let heightMapped = aspectMappedToHeight(size.height)
  	return binding ? min(widthMapped, heightMapped) : max(widthMapped, heightMapped)
  }
}

public func max(s1: CGSize, s2: CGSize) -> CGSize { return s1 > s2 ? s1 : s2 }
public func min(s1: CGSize, s2: CGSize) -> CGSize { return s1 < s2 ? s1 : s2 }

public func +(lhs: CGSize, rhs: CGSize) -> CGSize {
	return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
}

public func -(lhs: CGSize, rhs: CGSize) -> CGSize {
	return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
}

public func >(lhs: CGSize, rhs: CGSize) -> Bool { return lhs.area > rhs.area }
public func <(lhs: CGSize, rhs: CGSize) -> Bool { return lhs.area < rhs.area }
public func >=(lhs: CGSize, rhs: CGSize) -> Bool { return lhs.area >= rhs.area }
public func <=(lhs: CGSize, rhs: CGSize) -> Bool { return lhs.area <= rhs.area }

public func *(lhs: CGSize, rhs: CGFloat) -> CGSize { return CGSize(width: lhs.width * rhs, height: lhs.height * rhs) }
public func *(lhs: CGFloat, rhs: CGSize) -> CGSize { return rhs * lhs }
public func ∪(lhs: CGSize, rhs: CGSize) -> CGSize {
  return CGSize(width: max(lhs.width, rhs.width), height: max(lhs.height, rhs.height))
}

extension UIEdgeInsets {
  public func insetRect(rect: CGRect) -> CGRect {
    return UIEdgeInsetsInsetRect(rect, self)
  }
}

extension CGRect {
  public init(size: CGSize) { self = CGRect(x: 0, y: 0, width: size.width, height: size.height) }
  public init(size: CGSize, center: CGPoint) {
  	self = CGRect(x: center.x - size.width / CGFloat(2.0),
						  	  y: center.y - size.height / CGFloat(2.0),
						  	  width: size.width,
						  	  height: size.height)
  }
  public var center: CGPoint { return CGPoint(x: midX, y: midY) }
  public func rectWithOrigin(origin: CGPoint) -> CGRect { return CGRect(origin: origin, size: size) }
  public func rectWithSize(size: CGSize, anchored: Bool = false) -> CGRect {
  	var rect =  CGRect(origin: origin, size: size)
  	if anchored { rect.offset(dx: midX - rect.midX, dy: midY - rect.midY) }
  	return rect
  }
  public func rectWithHeight(height: CGFloat) -> CGRect {
  	return CGRect(origin: origin, size: CGSize(width: size.width, height: height))
  }
  public func rectWithWidth(width: CGFloat) -> CGRect {
  	return CGRect(origin: origin, size: CGSize(width: width, height: size.height))
  }
  public func rectWithCenter(center: CGPoint) -> CGRect { return CGRect(size: size, center: center) }
  public func rectByBindingToRect(rect: CGRect) -> CGRect {
  	let slaveMinX = minX
  	let slaveMaxX = maxX
  	let slaveMinY = minY
  	let slaveMaxY = maxY

  	let masterMinX = rect.minX
  	let masterMaxX = rect.maxX
  	let masterMinY = rect.minY
  	let masterMaxY = rect.maxY

  	let pushX = slaveMinX >= masterMinX ? 0.0 : masterMinX - slaveMinX
  	let pushY = slaveMinY >= masterMinY ? 0.0 : masterMinY - slaveMinY
  	let pullX = slaveMaxX <= masterMaxX ? 0.0 : slaveMaxX - masterMaxX
  	let pullY = slaveMaxY <= masterMaxY ? 0.0 : slaveMaxY - masterMaxY

  	return CGRect(x: origin.x + pushX + pullX,
  		            y: origin.y + pushY + pullY,
                  width: min(size.width + pushX + pullY, size.width),
                  height: min(size.height + pushY + pullY, size.height))
  }
}

public func -(lhs: UIOffset, rhs: UIOffset) -> UIOffset {
	return UIOffset(horizontal: lhs.horizontal - rhs.horizontal, vertical: lhs.vertical - rhs.vertical)
}

public func +(lhs: UIOffset, rhs: UIOffset) -> UIOffset {
	return UIOffset(horizontal: lhs.horizontal + rhs.horizontal, vertical: lhs.vertical + rhs.vertical)
}
