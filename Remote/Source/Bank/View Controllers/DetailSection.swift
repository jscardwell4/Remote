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

  var title: String?
  var identifier: DetailSectionHeader.Identifier { return .Header }
  let section: Int

  var count: Int { return blocks.count }

  var rows: LazyRandomAccessCollection<MapCollectionView<[(index: Int, element: () -> DetailRow)], DetailRow>> {
    let enumeratedBlocks = Array(enumerate(blocks))
    let lazyEnumeratedBlocks = lazy(enumeratedBlocks)
    return lazyEnumeratedBlocks.map {
      (index: Int, element: (Void) -> DetailRow) -> DetailRow in

      var row = element()
      row.indexPath = NSIndexPath(forRow: index, inSection: self.section)
      return row
    }
  }

  /**
  configureHeader:

  :param: header DetailSectionHeader
  */
  func configureHeader(header: DetailSectionHeader) {
    header.title = title
  }

  private var blocks: [() -> DetailRow] = []

  /**
  subscript:

  :param: row Int

  :returns: DetailRow?
  */
  subscript(row: Int) -> DetailRow { assert(row < count); return rows[row] }

  /**
  insertRow:atIndex:

  :param: row DetailRow
  :param: idx Int
  */
  func insertRow(row: DetailRow, atIndex idx: Int) { assert(idx <= count); blocks.insert({row}, atIndex: idx) }

  /**
  removeRowAtIndex:

  :param: idx Int
  */
  func removeRowAtIndex(idx: Int) { assert(idx < count); _ = blocks.removeAtIndex(idx) }

  /**
  removeAllRows:

  :param: keepCapacity Bool = false
  */
  func removeAllRows(keepCapacity: Bool = false) { blocks.removeAll(keepCapacity: keepCapacity) }

  /**
  addRow:

  :param: createRow (Void) -> DetailRow
  */
  func addRow(createRow: (Void) -> DetailRow) { blocks.append(createRow) }

  /**
  initWithSectionNumber:title:

  :param: section Int
  :param: title String? = nil
  */
  init(section: Int, title: String? = nil) { self.section = section; self.title = title }
}
