//
//  FilteringDetailSection.swift
//  Remote
//
//  Created by Jason Cardwell on 12/12/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

final class FilteringDetailSection: DetailSection {

  override var identifier: DetailSectionHeader.Identifier { return .FilteringHeader }

  var singleRowDisplay = false

  class Predicate {
    let name: String
    let includeRow: (DetailRow) -> Bool
    var active: Bool

    init(name: String, includeRow: (DetailRow) -> Bool, active: Bool = false) {
      self.name = name
      self.includeRow = includeRow
      self.active = active
    }
  }

  var defaultRow: DetailRow?

  var predicates: [Predicate] = []

  var activePredicatesDidChange: ((FilteringDetailSection) -> Void)?

  var filteredRows: LazySequence<FilterSequenceView<MapCollectionView<OrderedDictionary<String, () -> DetailRow>, DetailRow>>> {
    return rows.filter {
      (row: DetailRow) -> Bool in

      for predicate in self.predicates {
        let isSatisfied = predicate.includeRow(row)
        if predicate.active && !isSatisfied { return false }
        else if isSatisfied && !predicate.active { return false }
      }

      return true
     }
  }

  override var count: Int {
    let filteredRowsCount = filteredRows.array.count
    return filteredRowsCount > 0 ? filteredRowsCount : (defaultRow != nil ? 1 : 0)
  }

  /**
  subscript:

  :param: row Int

  :returns: DetailRow?
  */
  override subscript(row: Int) -> DetailRow {
    assert(row < count)
    let filteredRowsArray = filteredRows.array
    if row < filteredRowsArray.count { return filteredRowsArray[row] }
    else {
      assert(row == 0 && defaultRow != nil)
      return defaultRow!
    }
  }

  /**
  configureHeader:

  :param: header DetailSectionHeader
  */
  override func configureHeader(header: DetailSectionHeader) {
    super.configureHeader(header)

    if let filteringHeader = header as? FilteringDetailSectionHeader {
      filteringHeader.predicates = predicates
      filteringHeader.activePredicatesDidChange = {
        self.activePredicatesDidChange?(self)
        if self.singleRowDisplay {
          self.controller?.reloadRowAtIndexPath(NSIndexPath(forRow: 0, inSection: self.section), withRowAnimation: .Fade)
        } else {
          self.controller?.reloadSection(self, withRowAnimation: .Fade)
        }
      }
    }
  }

}
