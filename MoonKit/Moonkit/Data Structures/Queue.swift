//
//  Queue.swift
//  Remote
//
//  Created by Jason Cardwell on 5/05/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

private struct QueueNode<T> {
  var next: Box<QueueNode<T>?> = Box(nil)
  var value: T
  init(_ v: T) { value = v }
}

public struct Queue<T> {

  private var head: QueueNode<T>?
  private var tail: QueueNode<T>?


  /**
  dequeue

  :returns: T?
  */
  public mutating func dequeue() -> T? {
    let value = head?.value
    if head != nil {
      head = head?.next.unbox
      count--
      if count < 2 { tail = head }
    }
    return value
  }


  /**
  enqueue:

  :param: value T
  */
  public mutating func enqueue(value: T) {
    let node = QueueNode(value)
    if var t = tail {
      t.next = Box(node)
      tail = t
    } else {
      head = node
      tail = node
    }
    count++
  }

  /** empty */
  public mutating func empty() {
    head = nil
    tail = nil
    count = 0
  }

  public var isEmpty: Bool { return count == 0 }

  public private(set) var count: Int = 0

  public init() {}
}