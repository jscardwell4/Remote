//
//  BankCollectionViewHeader.swift
//  Remote
//
//  Created by Jason Cardwell on 9/15/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit

@objc(BankCollectionViewHeader)
class BankCollectionViewHeader: UICollectionReusableView {

  var title: String? { get { return button?.titleForState(.Normal) }
                       set { button?.setTitle(newValue, forState: .Normal) } }

  var section: Int = -1

  var toggleActionHandler: ((header: BankCollectionViewHeader) -> Void)?

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
      button.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
      button.addTarget(self, action: "toggleAction:", forControlEvents: .TouchUpInside)
      self.addSubview(button)
      return button
    }()
    constrainWithFormat("|-18-[button]-18-| :: button.centerY = self.centerY", views: ["button": button!])
  }

  override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
    
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