//
//  ObjcIO.swift
//  MoonKit
//
// Functions from "Functional Programming in Swift", www.objc.io
//
//  Created by Jason Cardwell on 4/8/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation


infix operator >>> { associativity left }

/** Compose operator */
public func >>> <A, B, C>( f: A -> B, g: B -> C) -> A -> C { return { x in g(f(x)) } }

/** The curry functions turn a function with x arguments into a series of x functions, each accepting one argument. */
public func curry <A, B, C>( f: (A, B) -> C) -> A -> B -> C {
  return { x in { y in f(x, y) } }
}
public func curry <A, B, C, D>( f: (A, B, C) -> D) -> A -> B -> C -> D {
  return { a in { b in { c in f( a, b, c) } } }
}

/** The flip function reverses the order of the arguments of the function you pass into it. */
public func flip <A, B, C>( f: (B, A) -> C) -> (A, B) -> C { return { (x, y) in f(y, x) } }
