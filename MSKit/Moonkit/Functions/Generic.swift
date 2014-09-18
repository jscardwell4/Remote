//
//  Generic.swift
//  HomeRemote
//
//  Created by Jason Cardwell on 8/5/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

func apply<T: SequenceType>(sequence:T, block:(T.Generator.Element)->()) {
  for element in sequence { block(element) }
}

infix operator ⩢ {}
func ⩢ <T:Equatable>(lhs: T, rhs: T!) -> Bool { return rhs == nil || lhs == rhs }

func ∈ <T, U where U:IntervalType, T == U.Bound>(lhs:T, rhs:U) -> Bool {
  return rhs.contains(lhs)
}

func ∋ <T, U where U:IntervalType, T == U.Bound>(lhs:U, rhs:T) -> Bool {
  return lhs.contains(rhs)
}

func ∉ <T, U where U:IntervalType, T == U.Bound>(lhs:T, rhs:U) -> Bool {
  return !(lhs ∈ rhs)
}

func ∌ <T, U where U:IntervalType, T == U.Bound>(lhs:U, rhs:T) -> Bool {
  return !(lhs ∋ rhs)
}