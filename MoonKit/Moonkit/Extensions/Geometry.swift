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
  public static var nullPoint: CGPoint = CGPoint(x: CGFloat.NaN, y: CGFloat.NaN)
  public var isNull: Bool { return self == CGPoint.nullPoint }
  public func xDelta(point: CGPoint) -> CGFloat { return point.isNull ? x : x - point.x }
  public func yDelta(point: CGPoint) -> CGFloat { return point.isNull ? y : y - point.y }
  public func delta(point: CGPoint) -> CGPoint { return self - point }
  public func absXDelta(point: CGPoint) -> CGFloat { return abs(xDelta(point)) }
  public func absYDelta(point: CGPoint) -> CGFloat { return abs(yDelta(point)) }
  public func absDelta(point: CGPoint) -> CGPoint { return (self - point).absolute }
  public mutating func transform(transform: CGAffineTransform) { self = pointByApplyingTransform(transform) }
  public var absolute: CGPoint { return self.isNull ? self :  CGPoint(x: abs(x), y: abs(y)) }
  public func pointByApplyingTransform(transform: CGAffineTransform) -> CGPoint {
    return CGPointApplyAffineTransform(self, transform)
  }
  public var max: CGFloat { return y > x ? y : x }
  public var min: CGFloat { return y < x ? y : x }
  public init(_ vector: CGVector) { x = vector.dx; y = vector.dy }
}

extension CGPoint: NilLiteralConvertible {
  public init(nilLiteral: ()) { self = CGPoint.nullPoint }
}

extension CGPoint: Unpackable2 {
  public func unpack() -> (CGFloat, CGFloat) { return (x, y) }
}

public func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
  return lhs.isNull ? rhs : (rhs.isNull ? lhs : CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y))
}
public func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
  return lhs.isNull ? rhs : (rhs.isNull ? lhs : CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y))
}
public func -=(inout lhs: CGPoint, rhs: CGPoint) { lhs = lhs - rhs }
public func +=(inout lhs: CGPoint, rhs: CGPoint) { lhs = lhs + rhs }
public func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint { return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs) }
public func /=(inout lhs: CGPoint, rhs: CGFloat) { lhs = lhs / rhs }
public func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint { return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs) }
public func *=(inout lhs: CGPoint, rhs: CGFloat) { lhs = lhs * rhs }

extension CGVector {
  public static var nullVector: CGVector = CGVector(dx: CGFloat.NaN, dy: CGFloat.NaN)
  public var isNull: Bool { return self == CGVector.nullVector }
  public func dxDelta(vector: CGVector) -> CGFloat { return vector.isNull ? dx : dx - vector.dx }
  public func dyDelta(vector: CGVector) -> CGFloat { return vector.isNull ? dy : dy - vector.dy }
  public func delta(vector: CGVector) -> CGVector { return self - vector }
  public func absDXDelta(vector: CGVector) -> CGFloat { return abs(dxDelta(vector)) }
  public func absDYDelta(vector: CGVector) -> CGFloat { return abs(dyDelta(vector)) }
  public func absDelta(vector: CGVector) -> CGVector { return (self - vector).absolute }
  public var absolute: CGVector { return isNull ? self : CGVector(dx: abs(dx), dy: abs(dy)) }
  public init(_ point: CGPoint) { dx = point.x; dy = point.y }
}

extension CGVector: NilLiteralConvertible {
  public init(nilLiteral: ()) { self = CGVector.nullVector }
}

extension CGVector: Printable {
  public var description: String { return "(\(dx), \(dy))"}
}

extension CGVector: Unpackable2 {
  public func unpack() -> (CGFloat, CGFloat) { return (dx, dy) }
}

public func -(lhs: CGVector, rhs: CGVector) -> CGVector {
  return lhs.isNull ? rhs : (rhs.isNull ? lhs : CGVector(dx: lhs.dx - rhs.dx, dy: lhs.dy - rhs.dy))
}
public func +(lhs: CGVector, rhs: CGVector) -> CGVector {
  return lhs.isNull ? rhs : (rhs.isNull ? lhs : CGVector(dx: lhs.dx + rhs.dx, dy: lhs.dy + rhs.dy))
}
public func -=(inout lhs: CGVector, rhs: CGVector) { lhs = lhs - rhs }
public func +=(inout lhs: CGVector, rhs: CGVector) { lhs = lhs + rhs }
public func /(lhs: CGVector, rhs: CGFloat) -> CGVector { return CGVector(dx: lhs.dx / rhs, dy: lhs.dy / rhs) }
public func /=(inout lhs: CGVector, rhs: CGFloat) { lhs = lhs / rhs }
public func *(lhs: CGVector, rhs: CGFloat) -> CGVector { return CGVector(dx: lhs.dx * rhs, dy: lhs.dy * rhs) }
public func *=(inout lhs: CGVector, rhs: CGFloat) { lhs = lhs * rhs }

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
  public mutating func transform(transform: CGAffineTransform) {
    self = sizeByApplyingTransform(transform)
  }
  public func sizeByApplyingTransform(transform: CGAffineTransform) -> CGSize {
    return CGSizeApplyAffineTransform(self, transform)
  }
}
extension CGSize: Unpackable2 {
  public func unpack() -> (CGFloat, CGFloat) { return (width, height) }
}

public func max(s1: CGSize, s2: CGSize) -> CGSize { return s1 > s2 ? s1 : s2 }
public func min(s1: CGSize, s2: CGSize) -> CGSize { return s1 < s2 ? s1 : s2 }

public func +(lhs: CGSize, rhs: CGSize) -> CGSize {
	return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
}

public func +(lhs: CGSize, rhs: CGFloat) -> CGSize { return CGSize(width: lhs.width + rhs, height: lhs.height + rhs) }

public func -(lhs: CGSize, rhs: CGSize) -> CGSize {
	return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
}
public func -(lhs: CGSize, rhs: CGFloat) -> CGSize { return CGSize(width: lhs.width - rhs, height: lhs.height - rhs) }

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
  public static var zeroInsets: UIEdgeInsets { return UIEdgeInsets(inset: 0) }
  public init(inset: CGFloat) { self = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset) }
}

extension UIEdgeInsets: Unpackable4 {
  public func unpack() -> (CGFloat, CGFloat, CGFloat, CGFloat) { return (top, left, bottom, right) }
}

extension CGAffineTransform {
  public init(tx: CGFloat, ty: CGFloat) { self = CGAffineTransformMakeTranslation(tx, ty) }
  public init(translation: CGPoint) { self = CGAffineTransform(tx: translation.x, ty: translation.y) }
  public init(sx: CGFloat, sy: CGFloat) { self = CGAffineTransformMakeScale(sx, sy) }
  public init(angle: CGFloat) { self = CGAffineTransformMakeRotation(angle) }
  public var isIdentity: Bool { return CGAffineTransformIsIdentity(self) }
  public mutating func translate(tx: CGFloat, ty: CGFloat) { self = translated(tx, ty) }
  public func translated(tx: CGFloat, _ ty: CGFloat) -> CGAffineTransform { return CGAffineTransformTranslate(self, tx, ty) }
  public mutating func scale(sx: CGFloat, sy: CGFloat) { self = scaled(sx, sy) }
  public func scaled(sx: CGFloat, _ sy: CGFloat) -> CGAffineTransform { return CGAffineTransformScale(self, sx, sy) }
  public mutating func rotate(angle: CGFloat) { self = rotated(angle) }
  public func rotated(angle: CGFloat) -> CGAffineTransform { return CGAffineTransformRotate(self, angle) }
  public mutating func invert() { self = inverted }
  public var inverted: CGAffineTransform { return CGAffineTransformInvert(self) }
  public static var identityTransform: CGAffineTransform { return CGAffineTransformIdentity }
}

public func +(lhs: CGAffineTransform, rhs: CGAffineTransform) -> CGAffineTransform { return CGAffineTransformConcat(lhs, rhs) }
public func +=(inout lhs: CGAffineTransform, rhs: CGAffineTransform) { lhs = lhs + rhs }
public func ==(lhs: CGAffineTransform, rhs: CGAffineTransform) -> Bool { return CGAffineTransformEqualToTransform(lhs, rhs) }

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
  public mutating func transform(transform: CGAffineTransform) {
    self = rectByApplyingTransform(transform)
  }
  public func rectByApplyingTransform(transform: CGAffineTransform) -> CGRect {
    return CGRectApplyAffineTransform(self, transform)
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

extension CGRect: Unpackable4 {
  public func unpack() -> (CGFloat, CGFloat, CGFloat, CGFloat) { return (origin.x, origin.y, size.width, size.height) }
}

public func ∪(lhs: CGRect, rhs: CGRect) -> CGRect { return lhs.rectByUnion(rhs) }

public func ∩(lhs: CGRect, rhs: CGRect) -> CGRect { return lhs.rectByIntersecting(rhs) }

public func ∪=(inout lhs: CGRect, rhs: CGRect) { lhs.union(rhs) }

public func ∩=(inout lhs: CGRect, rhs: CGRect) { lhs.intersect(rhs) }

public func -(lhs: UIOffset, rhs: UIOffset) -> UIOffset {
	return UIOffset(horizontal: lhs.horizontal - rhs.horizontal, vertical: lhs.vertical - rhs.vertical)
}

public func +(lhs: UIOffset, rhs: UIOffset) -> UIOffset {
	return UIOffset(horizontal: lhs.horizontal + rhs.horizontal, vertical: lhs.vertical + rhs.vertical)
}