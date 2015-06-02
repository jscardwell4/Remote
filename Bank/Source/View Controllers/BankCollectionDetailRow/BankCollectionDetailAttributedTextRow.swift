//
//  BankCollectionDetailAttributedTextRow.swift
//  Remote
//
//  Created by Jason Cardwell on 11/28/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

final class BankCollectionDetailAttributedTextRow: BankCollectionDetailRow {

  override var identifier: BankCollectionDetailCell.Identifier { return .AttributedText }

  override var infoDataType: BankCollectionDetailCell.DataType? { get { return .AttributedStringData } set {} }

}
