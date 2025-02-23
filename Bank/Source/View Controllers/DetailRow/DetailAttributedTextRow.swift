//
//  DetailAttributedTextRow.swift
//  Remote
//
//  Created by Jason Cardwell on 11/28/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

final class DetailAttributedTextRow: DetailRow {

  override var identifier: DetailCell.Identifier { return .AttributedText }

  override var infoDataType: DetailCell.DataType? { get { return .AttributedStringData } set {} }

}
