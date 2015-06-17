//
//  BankCollectionFilteringDetailSection.swift
//  Remote
//
//  Created by Jason Cardwell on 6/02/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

final class BankCollectionFilteringDetailSection: BankCollectionDetailSection {

  typealias FilteringHeader = BankCollectionFilteringDetailSectionHeader

  override var identifier: Header.Identifier { return .FilteringHeader }

  var singleRowDisplay = false

  class Predicate {
    let name: String
    let includeRow: (Row) -> Bool
    var active: Bool

    init(name: String, includeRow: (Row) -> Bool, active: Bool = false) {
      self.name = name
      self.includeRow = includeRow
      self.active = active
    }
  }

  var defaultRow: Row?

  var predicates: [Predicate] = []

  var activePredicatesDidChange: ((BankCollectionFilteringDetailSection) -> Void)?

  var filteredRows: LazySequence<FilterSequenceView<MapCollectionView<ConstructorIndex, Row>>> {
    return rows.filter {
      (row: Row) -> Bool in

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

  - parameter row: Int

  - returns: Row
  */
  override subscript(row: Int) -> Row {
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

  - parameter header: Header
  */
  override func configureHeader(header: Header) {
    super.configureHeader(header)

    if let filteringHeader = header as? FilteringHeader {
      filteringHeader.predicates = predicates
      filteringHeader.activePredicatesDidChange = {
        self.activePredicatesDidChange?(self)
        if self.singleRowDisplay { self.controller?.reloadItemAtIndexPath(NSIndexPath(forRow: 0, inSection: self.section)) }
         else { self.controller?.reloadSection(self) }
      }
    }
  }

}