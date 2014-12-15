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

  weak var controller: DetailController?
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
  func insertRow(row: DetailRow, atIndex idx: Int) { insertRow({row}, atIndex: idx) }

  /**
  insertRow:atIndex:

  :param: createRow (Void) -> DetailRow
  :param: idx Int
  */
  func insertRow(createRow: (Void) -> DetailRow, atIndex idx: Int) {
    assert(idx <= blocks.count)
    blocks.insert(createRow, atIndex: idx)
  }

  /**
  removeRowAtIndex:

  :param: idx Int
  */
  func removeRowAtIndex(idx: Int) { assert(idx < blocks.count); _ = blocks.removeAtIndex(idx) }

  /**
  replaceRowAtIndex:withRow:

  :param: idx Int
  :param: row (Void) -> DetailRow
  */
  func replaceRowAtIndex(idx: Int, withRow row: (Void) -> DetailRow) { assert(idx < blocks.count); blocks[idx] = row }

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
  :param: controller DetailController? = nil
  */
  init(section: Int, title: String? = nil, controller: DetailController? = nil) {
    self.section = section
    self.title = title
    self.controller = controller
  }
}
