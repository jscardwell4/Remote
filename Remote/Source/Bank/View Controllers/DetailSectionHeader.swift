//
//  DetailSectionHeader.swift
//  Remote
//
//  Created by Jason Cardwell on 12/9/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class DetailSectionHeader: UITableViewHeaderFooterView {

  struct Action {
    let title: String
    let action: (Void) -> Void
  }

  var title: String? { didSet { setNeedsDisplay() } }

  var action: Action? { didSet { actionButton.setTitle(action?.title, forState: .Normal) } }

  /** invokeAction */
  func invokeAction() { action?.action() }

  private let actionButton: UIButton =  {
    let view = UIButton(autolayout: true)
    view.userInteractionEnabled = false
    view.titleLabel?.font = UIFont(name: "Elysio-ThinItalic", size: 15)
    view.titleLabel?.textAlignment = .Right;
    view.constrain("|[title]| :: V:|[title]|", views: ["title": view.titleLabel!])
    view.setTitleColor(UIColor(red: 0, green: 0.68627451, blue: 1, alpha: 1), forState:.Normal)
    return view
  }()


  /**
  init:

  :param: reuseIdentifier String?
  */
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)

    contentView.addSubview(actionButton)
    actionButton.addTarget(self, action: "invokeAction", forControlEvents: .TouchUpInside)

    contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
    constrain("|[content]| :: V:|[content]|", views: ["content": contentView])
    contentView.constrain("[b]-| :: V:|-[b]-|", views: ["b": actionButton])

  }

  /**
  initWithFrame:

  :param: frame CGRect
  */
  override init(frame: CGRect) { super.init(frame: frame) }

  /**
  initWithCoder:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

  /** prepareForReuse */
  override func prepareForReuse() {
    title = nil
    action = nil
    super.prepareForReuse()
  }

  /**
  requiresConstraintBasedLayout

  :returns: Bool
  */
  override class func requiresConstraintBasedLayout() -> Bool { return true }

  /**
  drawRect:

  :param: rect CGRect
  */
  override func drawRect(rect: CGRect) { DrawingKit.drawSectionHeader(rect: rect, titleText: title ?? "") }

}
