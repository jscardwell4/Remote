//
//  SortingFunctions.swift
//  MoonKit
//
//  Created by Jason Cardwell on 5/14/15.
//  Copyright (c) 2015 Jason Cardwell. All rights reserved.
//

import Foundation

/**
sortedByName:

:param: seq S

:returns: [S.Generator.Element]
*/
public func sortedByName<S:SequenceType where S.Generator.Element:Nameable>(seq: S) -> [S.Generator.Element] {
  return Array(seq).sorted{$0.0.name < $0.1.name}
}

/**
sortedByName:

:param: seq S?

:returns: [S.Generator.Element]?
*/
public func sortedByName<S:SequenceType where S.Generator.Element:Nameable>(seq: S?) -> [S.Generator.Element]? {
  if seq != nil {  return Array(seq!).sorted{$0.0.name < $0.1.name} } else { return nil }
}

/**
sortByName:

:param: array [T]
*/
public func sortByName<T: Nameable>(inout array: [T]) { array.sort{$0.0.name < $0.1.name} }

/**
sortByName:

:param: array [T]?
*/
public func sortByName<T: Nameable>(inout array: [T]?) { array?.sort{$0.0.name < $0.1.name} }

/**
sortedByName:

:param: seq S

:returns: [S.Generator.Element]
*/
public func sortedByName<S:SequenceType where S.Generator.Element:Named>(seq: S) -> [S.Generator.Element] {
  return Array(seq).sorted{$0.0.name < $0.1.name}
}

/**
sortedByName:

:param: seq S?

:returns: [S.Generator.Element]?
*/
public func sortedByName<S:SequenceType where S.Generator.Element:Named>(seq: S?) -> [S.Generator.Element]? {
  if seq != nil {  return Array(seq!).sorted{$0.0.name < $0.1.name} } else { return nil }
}

/**
sortByName:

:param: array [T]
*/
public func sortByName<T: Named>(inout array: [T]) { array.sort{$0.0.name < $0.1.name} }

/**
sortByName:

:param: array [T]?
*/
public func sortByName<T: Named>(inout array: [T]?) { array?.sort{$0.0.name < $0.1.name} }
