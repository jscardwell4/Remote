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
  private var _rows: [DetailRow] = []
  var rows: [DetailRow] { if _rows.count == 0 { createRows() }; return _rows }
  let sectionNumber: Int

  var count: Int { return rows.count }

  /** reloadRows */
  func reloadRows() { createRows() }

  /** updateIndexPaths */
  private func updateIndexPaths() {
    for (i, var row) in enumerate(_rows) {
      row.indexPath = NSIndexPath(forRow: i, inSection: sectionNumber)
      _rows[i] = row
    }
  }

  /**
  subscript:

  :param: row Int

  :returns: DetailRow?
  */
  subscript(row: Int) -> DetailRow? { return row < rows.count ? rows[row] : nil }

  /**
  reloadRowAtIndex:

  :param: index Int
  */
  func reloadRowAtIndex(index: Int) {
    if index < _rows.count {
      var row = rowCreationBlocks[index]()
      row.indexPath = NSIndexPath(forRow: index, inSection: sectionNumber)
      _rows[index] = row
    }
  }

  /**
  insertRow:atIndex:

  :param: row DetailRow
  :param: idx Int
  */
  func insertRow(row: DetailRow, atIndex idx: Int) {
    if idx < rowCreationBlocks.count {
      rowCreationBlocks.insert({row}, atIndex: idx)
      _rows.insert(row, atIndex: idx)
      updateIndexPaths()
    }
  }

  /**
  removeRowAtIndex:

  :param: idx Int
  */
  func removeRowAtIndex(idx: Int) {
    if idx < rowCreationBlocks.count {
      _ = rowCreationBlocks.removeAtIndex(idx)
      _rows.removeAtIndex(idx)
      updateIndexPaths()
    }
  }

  private var rowCreationBlocks: [(Void) -> DetailRow] = []

  /**
  addRow:

  :param: createRow (Void) -> DetailRow
  */
  func addRow(createRow: (Void) -> DetailRow) { rowCreationBlocks.append(createRow); updateIndexPaths() }

  /** createRows */
  private func createRows() {
    _rows.removeAll(keepCapacity: true)
    for i in 0 ..< rowCreationBlocks.count { _rows.append(rowCreationBlocks[i]()) }
    updateIndexPaths()
  }

  /**
  initWithSectionNumber:title:createRows:

  :param: sectionNumber Int
  :param: title String? = nil
  :param: createRows (Void) -> [DetailRow]
  */
  init(sectionNumber: Int, title: String? = nil) { self.sectionNumber = sectionNumber; self.title = title }
}
