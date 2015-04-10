//
//  Set+MoonKitAdditions.swift
//  MoonKit
//
//  Created by Jason Cardwell on 3/31/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation

// contains
//public func ∈<T>(lhs: T, rhs: Set<T>) -> Bool { return rhs.contains(lhs) }
public func ∈<T>(lhs: T, rhs: Set<T>) -> Bool { return rhs.contains(lhs) }
public func ∋<T>(lhs: Set<T>, rhs: T) -> Bool { return lhs.contains(rhs) }
public func ∉<T>(lhs: T, rhs: Set<T>) -> Bool { return !(lhs ∈ rhs) }
public func ∌<T>(lhs: Set<T>, rhs: T) -> Bool { return !(lhs ∋ rhs) }

// subset/superset
public func ⊂<S:SequenceType, T where S.Generator.Element == T>(lhs: Set<T>, rhs: S) -> Bool {
  return lhs.isStrictSubsetOf(rhs)
}
public func ⊃<S:SequenceType, T where S.Generator.Element == T>(lhs: Set<T>, rhs: S) -> Bool {
  return lhs.isStrictSupersetOf(rhs)
}
public func ⊄<S:SequenceType, T where S.Generator.Element == T>(lhs: Set<T>, rhs: S) -> Bool { return !(lhs ⊂ rhs) }
public func ⊅<S:SequenceType, T where S.Generator.Element == T>(lhs: Set<T>, rhs: S) -> Bool { return !(lhs ⊃ rhs) }
public func ⊆<S:SequenceType, T where S.Generator.Element == T>(lhs: Set<T>, rhs: S) -> Bool { return lhs.isSubsetOf(rhs) }
public func ⊇<S:SequenceType, T where S.Generator.Element == T>(lhs: Set<T>, rhs: S) -> Bool { return lhs.isSupersetOf(rhs) }
public func ⊈<S:SequenceType, T where S.Generator.Element == T>(lhs: Set<T>, rhs: S) -> Bool { return !(lhs ⊆ rhs) }
public func ⊉<S:SequenceType, T where S.Generator.Element == T>(lhs: Set<T>, rhs: S) -> Bool { return !(lhs ⊇ rhs) }

// union
public func ∪<S:SequenceType, T where S.Generator.Element == T>(lhs: Set<T>, rhs: S) -> Set<T> { return lhs.union(rhs) }

// minus
public func ∖<S:SequenceType, T where S.Generator.Element == T>(lhs: Set<T>, rhs: S) -> Set<T> { return lhs.subtract(rhs) }

// intersect
public func ∩<S:SequenceType, T where S.Generator.Element == T>(lhs: Set<T>, rhs: S) -> Set<T> { return lhs.intersect(rhs) }
