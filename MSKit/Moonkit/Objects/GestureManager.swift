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

  public enum ResponseType {
    case Begin, ReceiveTouch, RecognizeSimultaneously, BeRequiredToFail, RequireFailureOf

    /**
    isValidResponse:

    :param: response Any

    :returns: Bool
    */
    func isValidResponse(response: Any) -> Bool {
      switch self {
        case .Begin: return response is (UIGestureRecognizer) -> Bool
        case .ReceiveTouch: return response is (UIGestureRecognizer, UITouch) -> Bool
        default: return response is (UIGestureRecognizer, UIGestureRecognizer) -> Bool
      }
    }
  }

  private var _gestures: [UIGestureRecognizer:[ResponseType:Any]] = [:]
  public var gestures: [UIGestureRecognizer] { return Array(_gestures.keys) }

  /**
  filteredResponses:

  :param: responses [ResponseType Any]

  :returns: [ResponseType:Any]
  */
  private func filteredResponses(responses: [ResponseType:Any]) -> [ResponseType:Any] {
    var filteredResponses: [ResponseType:Any] = [:]
    for (responseType, response) in responses {
      if responseType.isValidResponse(response) { filteredResponses[responseType] = response }
    }
    return filteredResponses
  }

  /** init */
  public override init() { super.init() }

  /**
  initWithGestures:

  :param: gestures [UIGestureRecognizer [ResponseType Any]]
  */
  public init(gestures: [UIGestureRecognizer:[ResponseType:Any]]) {
    super.init()
    var filteredGestures: [UIGestureRecognizer:[ResponseType:Any]] = [:]
    for (gesture, responses) in gestures { gesture.delegate = self; filteredGestures[gesture] = filteredResponses(responses) }
    _gestures = filteredGestures
  }

  /**
  setResponses:forGesture:

  :param: responses [ResponseType Any]
  :param: gesture UIGestureRecognizer
  */
  public func setResponses(responses: [ResponseType:Any], forGesture gesture: UIGestureRecognizer) {
    gesture.delegate = self
    _gestures[gesture] = filteredResponses(responses)
  }

}

extension GestureManager: UIGestureRecognizerDelegate {

  /**
  gestureRecognizerShouldBegin:

  :param: gesture UIGestureRecognizer

  :returns: Bool
  */
  public func gestureRecognizerShouldBegin(gesture: UIGestureRecognizer) -> Bool {
    if let block = _gestures[gesture]?[.Begin] as? (UIGestureRecognizer) -> Bool {
      return block(gesture)
    }
    return true
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
    if let block = _gestures[gesture]?[.RecognizeSimultaneously] as? (UIGestureRecognizer, UIGestureRecognizer) -> Bool {
      return block(gesture, otherGesture)
    }
    return false
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
    if let block = _gestures[gesture]?[.RequireFailureOf] as? (UIGestureRecognizer, UIGestureRecognizer) -> Bool {
      return block(gesture, otherGesture)
    }
    return true
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
    if let block = _gestures[gesture]?[.BeRequiredToFail] as? (UIGestureRecognizer, UIGestureRecognizer) -> Bool {
      return block(gesture, otherGesture)
    }
    return true
  }

  /**
  gestureRecognizer:shouldReceiveTouch:

  :param: gesture UIGestureRecognizer
  :param: touch UITouch

  :returns: Bool
  */
  public func gestureRecognizer(gesture: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
    if let block = _gestures[gesture]?[.ReceiveTouch] as? (UIGestureRecognizer, UITouch) -> Bool {
      return block(gesture, touch)
    }
    return true
  }

}
