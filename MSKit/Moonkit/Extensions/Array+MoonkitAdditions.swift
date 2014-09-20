//
//  Array+MoonKitAdditions.swift
//  HomeRemote
//
//  Created by Jason Cardwell on 8/9/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

extension Array {
  mutating func replaceAll(value:Element) { for i in 0..<count { self[i] = value } }
}

func unique<T:Equatable>(array:[T]) -> [T] {
  var u: [T] = []
  for e in array { if e ∉ u { u.append(e) } }
  return u
}

func unique<T:Equatable>(inout array:[T]) { array = unique(array) }

infix operator ∈ 	{  // element of
  associativity none
  precedence 130
}
infix operator ∉ 	{  // not an element of
  associativity none
  precedence 130
}
infix operator ∋ 	{  // has as member
  associativity none
  precedence 130
}
infix operator ∌ 	{  // does not have as member
  associativity none
  precedence 130
}
infix operator ∖ 	{  // minus
  associativity none
  precedence 130
}
infix operator ∪ 	{  // union
  associativity none
  precedence 130
}
infix operator ∩ 	{  // intersection
  associativity none
  precedence 130
}
infix operator ∖= 	{  // minus equals
  associativity right
  precedence 90
}
infix operator ∪= 	{  // union equals
  associativity right
  precedence 90
  assignment
}
infix operator ∩= 	{  // intersection equals
  associativity right
  precedence 90
  assignment
}
infix operator ⊂ 	{  // subset of
  associativity none
  precedence 130
}
infix operator ⊄ 	{  // not a subset of
  associativity none
  precedence 130
}
infix operator ⊃ 	{  // superset of
  associativity none
  precedence 130
}
infix operator ⊅ 	{  // not a superset of
  associativity none
  precedence 130
}
postfix operator ⭆ {}

infix operator ⥢ {
  associativity right
  precedence 90
}
prefix operator ⇇ {}

prefix func ⇇<T>(array:[T]) -> (T, T) { return (array[0], array[1]) }

func ⥢<T>(inout lhs:(T, T), rhs:[T]) {
  lhs = (rhs[0], rhs[1])
}

func ∈<T:Equatable>(lhs:T, rhs:[T]) -> Bool { return contains(rhs, lhs) }
func ∋<T:Equatable>(lhs:[T], rhs:T) -> Bool { return rhs ∈ lhs }
func ∉<T:Equatable>(lhs:T, rhs:[T]) -> Bool { return !(lhs ∈ rhs) }
func ∌<T:Equatable>(lhs:[T], rhs:T) -> Bool { return !(lhs ∋ rhs) }
func ∪<T>(lhs:[T], rhs:[T]) -> [T] { var u = lhs; u += rhs; return u }
func ∖<T:Equatable>(lhs:[T], rhs:[T]) -> [T] { return lhs.filter { $0 ∉ rhs } }
func ∩<T:Equatable>(lhs:[T], rhs:[T]) -> [T] { return unique(lhs ∪ rhs).filter {$0 ∈ lhs && $0 ∈ rhs} }
func ∪=<T>(inout lhs:[T], rhs:[T]) -> [T] { lhs += rhs; return lhs }
func ∖=<T:Equatable>(inout lhs:[T], rhs:[T]) -> [T] { lhs = lhs.filter { $0 ∉ rhs }; return lhs }
func ∩=<T:Equatable>(inout lhs:[T], rhs:[T]) -> [T] {
  lhs = unique(lhs ∪ rhs).filter {$0 ∈ lhs && $0 ∈ rhs}
  return lhs
}
func ⊂<T:Equatable>(lhs:[T], rhs:[T]) -> Bool { return lhs.filter {$0 ∉ rhs}.isEmpty }
func ⊄<T:Equatable>(lhs:[T], rhs:[T]) -> Bool { return !(lhs ⊂ rhs) }
func ⊃<T:Equatable>(lhs:[T], rhs:[T]) -> Bool { return rhs ⊂ lhs }
func ⊅<T:Equatable>(lhs:[T], rhs:[T]) -> Bool { return !(lhs ⊃ rhs) }

postfix func ⭆<T where T:GeneratorType>(var generator: T) -> [T.Element] {
  var result: [T.Element] = []
  var done = false
  while !done { if let e = generator.next() { result += [e] } else { done = true } }
  return result
}
