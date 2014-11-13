//
//  MSButton.swift
//  MSKit
//
//  Created by Jason Cardwell on 10/10/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

public class MSButton: UIButton {

  private var backgroundColors: [UInt:UIColor?] = [0:nil, 1:nil, 2:nil, 3:nil, 4:nil, 5:nil, 6:nil, 7:nil]

  public override init() { super.init() }

  public required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }


  /**
  setBackgroundColor:forState:

  :param: color UIColor?
  :param: state UIControlState
  */
  public func setBackgroundColor(color: UIColor?, forState state: UIControlState) {
    if (0...7).contains(state.rawValue) {
      backgroundColors[state.rawValue] = color
      if state == self.state { backgroundColor = color }
    }
  }

  /**
  backgroundColorForState:

  :param: state UIControlState

  :returns: UIColor?
  */
  public func backgroundColorForState(state: UIControlState) -> UIColor? {
    var color = backgroundColors[state.rawValue]!
    if color == nil && state & UIControlState.Highlighted == UIControlState.Highlighted  {
      color = backgroundColors[UIControlState.Highlighted.rawValue]!
    }
    if color == nil && state & UIControlState.Selected == UIControlState.Selected {
      color = backgroundColors[UIControlState.Selected.rawValue]!
    }
    if color == nil && state & UIControlState.Disabled == UIControlState.Disabled {
      color = backgroundColors[UIControlState.Disabled.rawValue]!
    }
    if color == nil {
      color = backgroundColors[UIControlState.Normal.rawValue]!
    }
    return color
  }

  public override var backgroundColor: UIColor? {
    get {
      let color = backgroundColorForState(state)
      if super.backgroundColor != color { super.backgroundColor = color }
      return super.backgroundColor
    }
    set { super.backgroundColor = newValue }
  }

  override public var enabled: Bool { didSet { backgroundColor = backgroundColorForState(state) } }
  override public var selected: Bool { didSet { backgroundColor = backgroundColorForState(state) } }
  override public var highlighted: Bool { didSet { backgroundColor = backgroundColorForState(state) } }

}
