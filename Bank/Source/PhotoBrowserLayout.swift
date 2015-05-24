//
//  PhotoBrowserLayout.swift
//  Remote
//
//  Created by Jason Cardwell on 5/24/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import UIKit
import MoonKit

class PhotoBrowserLayout: UICollectionViewFlowLayout {

  typealias AttributesIndex = OrderedDictionary<NSIndexPath, UICollectionViewLayoutAttributes>

  /**
  Creates a dictionary of attributes keyed by their index paths

  :param: attributes [UICollectionViewLayoutAttributes]

  :returns: AttributesIndex
  */
  private func attributesIndexWithAttributes(attributes: [UICollectionViewLayoutAttributes]) -> AttributesIndex {
    var attributesIndex: AttributesIndex = [:]
    apply(attributes){attributesIndex[$0.indexPath] = $0}
    return attributesIndex
  }

  private var unzoomingItem: NSIndexPath?
  private var zoomingItem: NSIndexPath?
  private var storedAttributes: AttributesIndex = [:]

  var zoomedItem: NSIndexPath? {
    willSet { if newValue == nil { unzoomingItem = zoomedItem } }
    didSet {
      if zoomedItem != nil { zoomingItem = zoomedItem }
      if let cv = collectionView, ip = zoomingItem ?? unzoomingItem {
        cv.performBatchUpdates({cv.deleteItemsAtIndexPaths([ip]); cv.insertItemsAtIndexPaths([ip])},
                    completion: {_ in self.zoomingItem = nil; self.unzoomingItem = nil})
      }
    }
  }

  /**
  zoomAttributes:

  :param: attributes UICollectionViewLayoutAttributes

  :returns: UICollectionViewLayoutAttributes
  */
  private func zoomAttributes(var attributes: UICollectionViewLayoutAttributes, zIndex: Int) -> UICollectionViewLayoutAttributes {
    if let collectionView = collectionView {
      let translate = CGAffineTransform(translation: collectionView.bounds.center - attributes.frame.center)
      let s = collectionView.bounds.width/itemSize.width
      let scale = CGAffineTransform(sx: s, sy: s)
      attributes.transform = scale + translate
      attributes.zIndex = zIndex
    }
    return attributes
  }

  /**
  layoutAttributesForElementsInRect:

  :param: rect CGRect

  :returns: [AnyObject]?
  */
  override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
    if var attributes = super.layoutAttributesForElementsInRect(rect) as? [UICollectionViewLayoutAttributes] {
      var attributesIndex = attributesIndexWithAttributes(attributes)
      if let ipZoom = zoomingItem, zoomedAttributes = attributesIndex[ipZoom] {
        attributes = map(attributesIndex) {
          idx, ip, attr -> UICollectionViewLayoutAttributes in
          if ip == ipZoom { return self.zoomAttributes(zoomedAttributes, zIndex: 100) }
          else if let storedAttr = self.storedAttributes[ip] { return storedAttr }
          else { return attr }
        }
        for attr in attributes { println("\(attr.indexPath.row): \(attr.frame)") }
      } else { storedAttributes.extend(attributesIndex) }
      return attributes
    } else { return nil }
  }

  override func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
    if let attributes = super.initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath) {
      if let indexPath = unzoomingItem where indexPath == itemIndexPath {
        MSLogDebug("unzoomingItem: \(attributes.frame)")
        return zoomAttributes(attributes, zIndex: 1)
      }
      else if let indexPath = zoomingItem where indexPath == itemIndexPath {
        MSLogDebug("zoomingItem: \(attributes.frame)")
        return attributes
      }
      else { return attributes }
    } else { return nil }
  }

}
