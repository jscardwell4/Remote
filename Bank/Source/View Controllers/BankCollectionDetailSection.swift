//
//  BankCollectionDetailSection.swift
//  Remote
//
//  Created by Jason Cardwell on 6/02/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankCollectionDetailSection {

  typealias Row = BankCollectionDetailRow
  typealias Key = String
  typealias RowConstructor = () -> Row
  typealias Header = BankCollectionDetailSectionHeader
  typealias Controller = BankCollectionDetailController
  typealias ConstructorIndex = OrderedDictionary<Key, RowConstructor>

  /** Keyed collection of row creation blocks */
  private var blocks: ConstructorIndex = [:]

  /** Cache for created rows */
  private var cache: [Key:Row] = [:]

  /** Weak reference to controller presenting this section */
  weak var controller: Controller?

  /** The title to display for the section */
  var title: String?

  /** Specifies which kind of header is ultimately used */
  var identifier: Header.Identifier { return .Header }

  /** The assigned section number */
  let section: Int

  /** Total number or row creation blocks */
  var count: Int { return blocks.count }

  /** Lazy collection that maps row creation blocks to their results */
  var rows: LazyRandomAccessCollection<MapCollectionView<ConstructorIndex, Row>> {
    return lazy(blocks).map {
      index, key, block -> Row in
      var row = block()
      row.indexPath = NSIndexPath(forRow: index, inSection: self.section)
      self.cache[key] = row
      return row
    }
  }

  /**
  Decorates the specified header using stored property values

  :param: header Header
  */
  func configureHeader(header: Header) { header.title = title }

  /**
  Access an individual row

  :param: row Int

  :returns: Row
  */
  subscript(row: Int) -> Row {
    precondition(row < count)
    return cache[blocks.keyForIndex(row)] ?? rows[row]
  }

  /**
  Insert a row by wrapping in a creation block that simply returns the row

  :param: row Row
  :param: idx Int
  :param: key Key
  */
  func insertRow(row: Row, atIndex idx: Int, forKey key: Key) {
    precondition(idx <= blocks.count)
    insertRow({row}, atIndex: idx, forKey: key)
    cache[key] = row
  }

  /**
  insertRow:atIndex:

  :param: createRow (Void) -> Row
  :param: idx Int
  */
  func insertRow(createRow: RowConstructor, atIndex idx: Int, forKey key: Key) {
    precondition(idx <= blocks.count)
    blocks.insertValue(createRow, atIndex: idx, forKey: key)
  }


  /**
  removeRowAtIndex:

  :param: idx Int
  */
  func removeRowAtIndex(idx: Int) {
    precondition(idx < blocks.count)
    cache[blocks.keyForIndex(idx)] = nil
    blocks.removeAtIndex(idx)
  }

  /**
  removeRowForKey:

  :param: key Key
  */
  func removeRowForKey(key: Key) {
    cache[key] = nil
    blocks[key] = nil
  }

  /**
  replaceRowAtIndex:withRow:

  :param: idx Int
  :param: row (Void) -> Row
  */
  func replaceRowAtIndex(idx: Int, withRow row: RowConstructor) {
    precondition(idx < blocks.count)
    cache[blocks.keyForIndex(idx)] = nil
    blocks.updateValue(row, atIndex: idx)
  }

  /**
  removeAllRows:

  :param: keepCapacity Bool = false
  */
  func removeAllRows(keepCapacity: Bool = false) {
    cache.removeAll(keepCapacity: keepCapacity)
    blocks.removeAll(keepCapacity: keepCapacity)
  }

  /**
  addRow:

  :param: createRow (Void) -> Row
  */
  func addRow(createRow: RowConstructor, forKey key: Key) {
    blocks[key] = createRow
  }

  /**
  initWithSectionNumber:title:

  :param: section Int
  :param: title String? = nil
  :param: controller Controller? = nil
  */
  init(section: Int, title: String? = nil, controller: Controller? = nil) {
    self.section = section
    self.title = title
    self.controller = controller
  }


}