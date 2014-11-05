//
//  RemoteElementEditingPresentationController.swift
//  Remote
//
//  Created by Jason Cardwell on 11/03/14.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import UIKit
import MoonKit

class RemoteElementEditingPresentationController: UIPresentationController {

	/**
	initWithPresentedViewController:presentingViewController:

	:param: presentedViewController UIViewController!
	:param: presentingViewController UIViewController!
	*/
	override init(presentedViewController: UIViewController!, presentingViewController: UIViewController!) {
		super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
	}

	/** presentationTransitionWillBegin */
	override func presentationTransitionWillBegin() {

	}

	/** dismissalTransitionWillBegin */
	override func dismissalTransitionWillBegin() {

	}

	/** containerViewWillLayoutSubviews */
	override func containerViewWillLayoutSubviews() {

	}

	/**
	animationControllerForDismissedController:

	:param: dismissed UIViewController!

	:returns: UIViewControllerAnimatedTransitioning!
	*/
	func animationControllerForDismissedController(dismissed: UIViewController!) -> UIViewControllerAnimatedTransitioning! {
		return RemoteElementEditingAnimatedTransitioning()
	}

}
