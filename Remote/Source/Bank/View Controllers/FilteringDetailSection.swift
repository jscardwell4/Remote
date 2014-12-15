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

class FilteringDetailSection: DetailSection {

  override var identifier: DetailSectionHeader.Identifier { return .FilteringHeader }

  struct Predicate {
    let name: String
    let includeRow: (DetailRow) -> Bool
  }

  var predicates: [Predicate] = []

  private var activePredicates: [Int] = []

  var filteredRows: LazySequence<FilterSequenceView<MapCollectionView<[(index: Int, element: () -> DetailRow)], DetailRow>>> {
    return rows.filter {
      (row: DetailRow) -> Bool in
        for idx in self.activePredicates { if !self.predicates[idx].includeRow(row) { return false } }
        return true
     }
  }

  override var count: Int { return filteredRows.array.count }

  /**
  configureHeader:

  :param: header DetailSectionHeader
  */
  override func configureHeader(header: DetailSectionHeader) {
    super.configureHeader(header)

    (header as? FilteringDetailSectionHeader)?.labels = predicates.map{$0.name}
  }

}
