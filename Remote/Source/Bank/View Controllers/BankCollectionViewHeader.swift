//
//  BankCollectionViewHeader.swift
//  Remote
//
//  Created by Jason Cardwell on 9/15/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit

class BankCollectionViewHeader: UICollectionReusableView {

  class var identifier: String { return "BankCollectionViewHeaderIdentifier" }

  var title: String? { get { return button?.titleForState(.Normal) }
                       set { button?.setTitle(newValue, forState: .Normal) } }

  var section: Int = -1
  
  weak var controller: BankCollectionViewController?

  private weak var button: UIButton!

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor(r: 136, g: 136, b: 136, a: 230)
    let button = UIButton(forAutoLayout:())
    button.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
    button.addTarget(self, action: "toggleItems:", forControlEvents: .TouchUpInside)
    self.addSubview(button)
    self.button = button
    self.addConstraints(
      NSLayoutConstraint.constraintsByParsingString("|-18-[button]-18-|\nbutton.centerY = self.centerY",
                                              views: ["button": button, "self": self])
    )
  }

  required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }


  /**

  toggleItems:

  :param: sender AnyObject?

  */
  func toggleItems(sender:AnyObject?) { controller?.toggleItemsForSection(section) }


}