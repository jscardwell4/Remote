//
//  BankModelDetailDelegate.swift
//  Remote
//
//  Created by Jason Cardwell on 6/02/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit
import DataModel

class BankModelDetailDelegate: ItemCreationTransactionProvider {

  typealias Section = BankCollectionDetailSection
  typealias SectionKey = String
  typealias SectionIndex = OrderedDictionary<SectionKey, Section>

  let item: DelegateDetailable

  init(item i: DelegateDetailable) { item = i }

  private(set) var sections: SectionIndex = [:]

  func loadSections(controller controller: BankCollectionDetailController) {
    sections = item.sectionIndexForController(controller)
  }

  var transactions: [ItemCreationTransaction] { return [] }
}