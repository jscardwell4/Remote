//
//  BankCollectionHeader.swift
//  Remote
//
//  Created by Jason Cardwell on 9/15/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit

@objc(BankCollectionHeader)
class BankCollectionHeader: UICollectionReusableView {

  var title: String? {
    didSet {
      button.setAttributedTitle(NSAttributedString(string: title ?? "", attributes: titleAttributes), forState: .Normal)
    }
  }

  private let titleAttributes: [String:AnyObject] = [
    NSFontAttributeName           : UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline),
    NSForegroundColorAttributeName: UIColor.whiteColor()
  ]

  var toggleActionHandler: ((header: BankCollectionHeader) -> Void)?

  private weak var button: UIButton!

  /**
  initWithFrame:

  :param: frame CGRect
  */
  override init(frame: CGRect) {
    super.init(frame: frame)

    backgroundColor = UIColor(r: 136, g: 136, b: 136, a: 230)

    button = { [unowned self] in
      let button = UIButton(forAutoLayout:())
      button.addTarget(self, action: "toggleAction:", forControlEvents: .TouchUpInside)
      self.addSubview(button)
      return button
    }()

    constrainWithFormat("button.center = self.center :: button.width = self.width :: button.height = self.height",
                  views: ["button": button!])

  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /**
  toggleAction
  */
  func toggleAction(sender: AnyObject?) { if let action = toggleActionHandler { action(header: self) } }


}