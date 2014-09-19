//
//  Stack.swift
//  MSKit
//
//  Created by Jason Cardwell on 9/17/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation

struct Stack<T> {

  private var storage: [T]

  var count: Int { return storage.count }
  var peek: T? { return storage.last }
  var isEmpty: Bool { return count == 0 }

  init() { storage = [T]() }
  init(objects:[T]) { storage = objects }
  init(object:T) { storage = [object] }

  /**
  map<U>:

  :param: transform (T) -> U

  :returns: [U]
  */
  func map<U>(transform: (T) -> U) -> [U] { return storage.map(transform) }

  /**
  pop

  :returns: T?
  */
  mutating func pop() -> T? { var obj: T? = nil; if count > 0 { obj = storage.removeLast() }; return obj }

  /**
  push:

  :param: obj T
  :param: count Int = 1
  */
  mutating func push(obj:T, count:Int = 1) { storage += [T](count: count, repeatedValue: obj) }

  /** empty */
  mutating func empty() { storage.removeAll(keepCapacity: false) }

  /** reverse */
  mutating func reverse() { storage.reverse() }

}

extension Stack: Printable {
  var description: String { return storage.description }
}

extension Stack: SequenceType, _Sequence_Type {
  func generate() -> Array<T>.Generator { return storage.generate() }
}

extension Stack: CollectionType, _CollectionType {
  var startIndex: Array<T>.Index { return storage.startIndex }
  var endIndex: Array<T>.Index { return storage.endIndex }
  subscript (i: Array<T>.Index) -> T { get { return storage[i] } set { storage[i] = newValue } }
}

extension Stack: ArrayLiteralConvertible {
  static func convertFromArrayLiteral(elements: T...) -> Stack<T> { return Stack<T>(objects: elements) }
}
