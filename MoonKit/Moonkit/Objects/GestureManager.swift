//
//  GestureManager.swift
//  MSKit
//
//  Created by Jason Cardwell on 10/27/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit

public class GestureManager: NSObject {

	/** A simple structure to hold response blocks for a single gesture */
	public struct ResponseCollection {
		var begin: (() -> Bool)?
		var receiveTouch: ((UITouch) -> Bool)?
		var recognizeSimultaneously: ((UIGestureRecognizer) -> Bool)?
		var beRequiredToFail: ((UIGestureRecognizer) -> Bool)?
		var requireFailureOf: ((UIGestureRecognizer) -> Bool)?

		/**
		initWithBegin:receiveTouch:recognizeSimultaneously:beRequiredToFail:requireFailureOf:

		:param: begin (() -> Bool)? = nil
		:param: receiveTouch ((UITouch) -> Bool)? = nil
		:param: recognizeSimultaneously ((UIGestureRecognizer) -> Bool)? = nil
		:param: beRequiredToFail ((UIGestureRecognizer) -> Bool)? = nil
		:param: requireFailureOf ((UIGestureRecognizer) -> Bool)? = nil
		*/
		public init(begin: (() -> Bool)? = nil,
								receiveTouch: ((UITouch) -> Bool)? = nil,
								recognizeSimultaneously: ((UIGestureRecognizer) -> Bool)? = nil,
								beRequiredToFail: ((UIGestureRecognizer) -> Bool)? = nil,
								requireFailureOf: ((UIGestureRecognizer) -> Bool)? = nil)
		{
			self.begin = begin
			self.receiveTouch = receiveTouch
			self.recognizeSimultaneously = recognizeSimultaneously
			self.beRequiredToFail = beRequiredToFail
			self.requireFailureOf = requireFailureOf
		}
	}

  private var _gestures: [UIGestureRecognizer:ResponseCollection] = [:]
  public var gestures: [UIGestureRecognizer] { return Array(_gestures.keys) }

  /** init */
  public override init() { super.init() }

  /**
  initWithGestures:

  :param: gestures [UIGestureRecognizer [ResponseType Any]]
  */
  public init(gestures: [UIGestureRecognizer:ResponseCollection]) {
    super.init()
    for (gesture, responseCollection) in gestures { setResponses(responseCollection, forGesture: gesture) }
  }

  /**
  setResponses:forGesture:

  :param: responses [ResponseType Any]
  :param: gesture UIGestureRecognizer
  */
  public func setResponses(responseCollection: ResponseCollection, forGesture gesture: UIGestureRecognizer) {
    gesture.delegate = self
    _gestures[gesture] = responseCollection
  }

}

extension GestureManager: UIGestureRecognizerDelegate {

  /**
  gestureRecognizerShouldBegin:

  :param: gesture UIGestureRecognizer

  :returns: Bool
  */
  public func gestureRecognizerShouldBegin(gesture: UIGestureRecognizer) -> Bool {
  	return _gestures[gesture]?.begin?() ?? true
  }

  /**
  gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:

  :param: gesture UIGestureRecognizer
  :param: otherGesture UIGestureRecognizer

  :returns: Bool
  */
  public func                       gestureRecognizer(gesture: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWithGestureRecognizer otherGesture: UIGestureRecognizer) -> Bool
  {
  	return _gestures[gesture]?.recognizeSimultaneously?(otherGesture) ?? false
  }

  /**
  gestureRecognizer:shouldRequireFailureOfGestureRecognizer:

  :param: gesture UIGestureRecognizer
  :param: otherGesture UIGestureRecognizer

  :returns: Bool
  */
  public func             gestureRecognizer(gesture: UIGestureRecognizer,
    shouldRequireFailureOfGestureRecognizer otherGesture: UIGestureRecognizer) -> Bool
  {
  	return _gestures[gesture]?.requireFailureOf?(otherGesture) ?? true
  }

  /**
  gestureRecognizer:shouldBeRequiredToFailByGestureRecognizer:

  :param: gesture UIGestureRecognizer
  :param: otherGesture UIGestureRecognizer

  :returns: Bool
  */
  public func               gestureRecognizer(gesture: UIGestureRecognizer,
    shouldBeRequiredToFailByGestureRecognizer otherGesture: UIGestureRecognizer) -> Bool
  {
  	return _gestures[gesture]?.beRequiredToFail?(otherGesture) ?? true
  }

  /**
  gestureRecognizer:shouldReceiveTouch:

  :param: gesture UIGestureRecognizer
  :param: touch UITouch

  :returns: Bool
  */
  public func gestureRecognizer(gesture: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
  	return _gestures[gesture]?.receiveTouch?(touch) ?? true
  }

}