//
//  RemoteView.swift
//  Remote
//
//  Created by Jason Cardwell on 11/07/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class RemoteView: RemoteElementView {

	/**
	intrinsicContentSize

	:returns: CGSize
	*/
	override func intrinsicContentSize() -> CGSize { return UIScreen.mainScreen().bounds.size }

	override var resizable: Bool { get { return false } set {} }
	override var moveable: Bool { get { return false } set {} }

	/** initializeIVARs */
	override func initializeIVARs() {
		setContentCompressionResistancePriority(1000.0, forAxis: .Horizontal)
		setContentCompressionResistancePriority(1000.0, forAxis: .Vertical)
		setContentHuggingPriority(1000.0, forAxis: .Horizontal)
		setContentHuggingPriority(1000.0, forAxis: .Vertical)
		super.initializeIVARs()
	}

}
