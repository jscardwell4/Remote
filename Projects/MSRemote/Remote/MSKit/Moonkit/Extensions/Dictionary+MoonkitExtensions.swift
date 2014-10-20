//
//  Dictionary+MoonKitExtensions.swift
//  HomeRemote
//
//  Created by Jason Cardwell on 8/7/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation

extension Dictionary {

  func hasKey(key:Key) -> Bool { return contains(self.keys, key) }

  init(objects:[Value], forKeys keys:[Key]) {
    self.init(minimumCapacity:keys.count)
    if keys.count == objects.count { for i in 0..<keys.count { self[keys[i]] = objects[i] } }
  }

}

func inverted<K:Hashable, V:Hashable>(dictionary:[K:V]) -> [V:K] {
  return [V:K](objects:Array(dictionary.keys), forKeys:Array(dictionary.values))
}

infix operator ⟾ {}

func ⟾ <K,V>(lhs:[K:V], rhs:[K:V]) -> [K:V] {
	var result = rhs
	for (k,v) in lhs { if Array(rhs.keys) ∋ k { result[k] = v } }
	return result
}

//func ⟾ <K,V>(lhs:[K:V], inout rhs:[K:V]) { for (k,v) in lhs { if Array(rhs.keys) ∋ k { rhs[k] = v } } }
