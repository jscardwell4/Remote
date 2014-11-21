//
//  OrderedSet_ObjectiveCBridgeable.swift
//  MSKit
//
//  Created by Jason Cardwell on 11/20/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
  import swift

extension OrderedSet: _ObjectiveCBridgeable {

  public typealias _ObjectiveCType = NSOrderedSet

  /// Return true iff instances of `Self` can be converted to
  /// Objective-C.  Even if this method returns `true`, A given
  /// instance of `Self._ObjectiveCType` may, or may not, convert
  /// successfully to `Self`; for example, an `NSArray` will only
  /// convert successfully to `[String]` if it contains only
  /// `NSString`\ s.
  public static func _isBridgedToObjectiveC() -> Bool { return true }

  /// Must return `_ObjectiveCType.self`.
  public static func _getObjectiveCType() -> Any.Type { return NSOrderedSet.self }

  /// Convert `self` to Objective-C
  public func _bridgeToObjectiveC() -> _ObjectiveCType {
    return NSOrderedSet(array: storage._bridgeToObjectiveC())
  }

  /// Bridge from an Objective-C object of the bridged class type to a
  /// value of the Self type.
  ///
  /// This bridging operation is used for forced downcasting (e.g.,
  /// via as), and may defer complete checking until later. For
  /// example, when bridging from NSArray to Array<T>, we can defer
  /// the checking for the individual elements of the array.
  ///
  /// :param: result The location where the result is written. The optional
  /// will always contain a value.
  public static func _forceBridgeFromObjectiveC(source: _ObjectiveCType, inout result: OrderedSet?) {
    if let a = Array<T>._bridgeFromObjectiveCAdoptingNativeStorage(source.array) {
      result = OrderedSet(a)
    }
  }

  /// Try to bridge from an Objective-C object of the bridged class
  /// type to a value of the Self type.
  ///
  /// This conditional bridging operation is used for conditional
  /// downcasting (e.g., via as?) and therefore must perform a
  /// complete conversion to the value type; it cannot defer checking
  /// to a later time.
  ///
  /// :param: result The location where the result is written.
  ///
  /// :returns: true if bridging succeeded, false otherwise. This redundant
  /// information is provided for the convenience of the runtime's dynamic_cast
  /// implementation, so that it need not look into the optional representation
  /// to determine success.
  public static func _conditionallyBridgeFromObjectiveC(source: _ObjectiveCType, inout result: OrderedSet?) -> Bool {
    if let a = Array<T>._bridgeFromObjectiveCAdoptingNativeStorage(source.array) {
      result = OrderedSet(a)
      return true
    }
    return false
  }

}
