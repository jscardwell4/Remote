//
//  BankItemDetailSection.swift
//  Remote
//
//  Created by Jason Cardwell on 10/16/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class BankItemDetailSection {

  var title: String?
  private var _rows: [BankItemDetailRow] = []
  var rows: [BankItemDetailRow] {
    if _rows.count == 0 { _rows = createRows() }
    return _rows
  }
  let sectionNumber: Int

  /** reloadRows */
  func reloadRows() {
    _rows = createRows()
  }

  /**
  reloadRowAtIndex:

  :param: index Int
  */
  func reloadRowAtIndex(index: Int) {
    if index < _rows.count {
      let row = rowCreationBlocks[index]()
      row.indexPath = NSIndexPath(forRow: index, inSection: sectionNumber)
      _rows[index] = row
    }
  }

  private var rowCreationBlocks: [(Void) -> BankItemDetailRow] = []

  /**
  addRow:

  :param: createRow (Void) -> BankItemDetailRow
  */
  func addRow(createRow: (Void) -> BankItemDetailRow) {
    rowCreationBlocks.append(createRow)
  }

  /** createRows */
  func createRows() -> [BankItemDetailRow] {
    var createdRows: [BankItemDetailRow] = []
    for i in 0 ..< rowCreationBlocks.count {
      let row = rowCreationBlocks[i]()
      row.indexPath = NSIndexPath(forRow: i, inSection: sectionNumber)
      createdRows.append(row)
    }
    return createdRows
  }

  /**
  initWithSectionNumber:title:createRows:

  :param: sectionNumber Int
  :param: title String? = nil
  :param: createRows (Void) -> [BankItemDetailRow]
  */
  init(sectionNumber: Int, title: String? = nil) {
    self.sectionNumber = sectionNumber
    self.title = title
  }
}
