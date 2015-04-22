//
//  DetailSection.swift
//  Remote
//
//  Created by Jason Cardwell on 10/16/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DetailSection {

  typealias RowConstructor = () -> DetailRow

  /** Keyed collection of row creation blocks */
  private var blocks: OrderedDictionary<String, RowConstructor> = [:]

  /** Cache for created rows */
  private var cache: [String:DetailRow] = [:]

  /** Weak reference to controller presenting this section */
  weak var controller: DetailController?

  /** The title to display for the section */
  var title: String?

  /** Specifies which kind of header is ultimately used */
  var identifier: DetailSectionHeader.Identifier { return .Header }

  /** The assigned section number */
  let section: Int

  /** Total number or row creation blocks */
  var count: Int { return blocks.count }

  /** Lazy collection that maps row creation blocks to their results */
  var rows: LazyRandomAccessCollection<MapCollectionView<OrderedDictionary<String, RowConstructor>, DetailRow>> {
    return lazy(blocks).map {
      index, key, block -> DetailRow in
      var row = block()
      row.indexPath = NSIndexPath(forRow: index, inSection: self.section)
      self.cache[key] = row
      return row
    }
  }

  /**
  Decorates the specified header using stored property values

  :param: header DetailSectionHeader
  */
  func configureHeader(header: DetailSectionHeader) { header.title = title }

  /**
  Access an individual row

  :param: row Int

  :returns: DetailRow
  */
  subscript(row: Int) -> DetailRow {
    precondition(row < count)
    return cache[blocks.keyForIndex(row)] ?? rows[row]
  }

  /**
  Insert a row by wrapping in a creation block that simply returns the row

  :param: row DetailRow
  :param: idx Int
  :param: key String
  */
  func insertRow(row: DetailRow, atIndex idx: Int, forKey key: String) {
    precondition(idx <= blocks.count)
    insertRow({row}, atIndex: idx, forKey: key)
    cache[key] = row
  }

  /**
  insertRow:atIndex:

  :param: createRow (Void) -> DetailRow
  :param: idx Int
  */
  func insertRow(createRow: RowConstructor, atIndex idx: Int, forKey key: String) {
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

  :param: key String
  */
  func removeRowForKey(key: String) {
    cache[key] = nil
    blocks[key] = nil
  }

  /**
  replaceRowAtIndex:withRow:

  :param: idx Int
  :param: row (Void) -> DetailRow
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

  :param: createRow (Void) -> DetailRow
  */
  func addRow(createRow: RowConstructor, forKey key: String) {
    blocks[key] = createRow
  }

  /**
  initWithSectionNumber:title:

  :param: section Int
  :param: title String? = nil
  :param: controller DetailController? = nil
  */
  init(section: Int, title: String? = nil, controller: DetailController? = nil) {
    self.section = section
    self.title = title
    self.controller = controller
  }

}
