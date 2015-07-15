//
//  InlinePickerView.swift
//  MSKit
//
//  Created by Jason Cardwell on 10/14/14.
//  Copyright (c) 2014 Jason Cardwell. All rights reserved.
//

import Foundation
import UIKit


public class InlinePickerView: UIView {

  /**
  initWithFrame:

  - parameter frame: CGRect
  */
  override public init(frame: CGRect) { super.init(frame: frame); initializeIVARs() }

  /**
  init:

  - parameter aDecoder: NSCoder
  */
  required public init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder); initializeIVARs() }

  /** initializeIVARs */
  private func initializeIVARs() {
//    MSLogDebug("")
    setContentCompressionResistancePriority(750, forAxis: .Horizontal)
    setContentCompressionResistancePriority(1000, forAxis: .Vertical)
    translatesAutoresizingMaskIntoConstraints = false
    nametag = "picker"

    addSubview(collectionView)
    collectionView.nametag = "collectionView"
    layout.delegate = self
    collectionView.scrollEnabled = false
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.bounces = false
    collectionView.backgroundColor = UIColor.clearColor()
    collectionView.decelerationRate = UIScrollViewDecelerationRateFast
    collectionView.layer.sublayerTransform =  usePerspective ? CATransform3D(
      m11: 1, m12: 0, m13: 0, m14: 0,
      m21: 0, m22: 1, m23: 0, m24: 0,
      m31: 0, m32: 0, m33: 0, m34: CGFloat(-1.0/1000.0),
      m41: 0, m42: 0, m43: 0, m44: 1
      ) : CATransform3DIdentity
    collectionView.registerClass(InlinePickerViewCell.self, forCellWithReuseIdentifier: "Cell")
    collectionView.reloadData()
  }

  override public func updateConstraints() {
    removeAllConstraints()
    super.updateConstraints()
    constrain(𝗛|collectionView|𝗛, 𝗩|collectionView|𝗩)
    constrain(height ≥ itemHeight)
  }

  private let collectionView = UICollectionView(frame: CGRect.zeroRect, collectionViewLayout: InlinePickerViewLayout())
  private var layout: InlinePickerViewLayout { return collectionView.collectionViewLayout as! InlinePickerViewLayout }

  override public class func requiresConstraintBasedLayout() -> Bool { return true }
  override public func intrinsicContentSize() -> CGSize { return CGSize(width: UIViewNoIntrinsicMetric, height: itemHeight) }

  override public var description: String {
    return super.description + "\n\t" + "\n\t".join(
      "labels = \(labels)",
      "collectionView = \(collectionView.description)",
      "collectionViewLayout = \(collectionView.collectionViewLayout.description)"
    )
  }

  /**
  selectItem:animated:

  - parameter item: Int
  - parameter animated: Bool
  */
  public func selectItem(item: Int, animated: Bool) {
    guard (0 ..< labels.count).contains(item) else { MSLogWarn("\(item) is not a valid item index"); return }

    selection = item
    if let offset = layout.offsetForItemAtIndex(selection) {
      collectionView.selectItemAtIndexPath(NSIndexPath(forItem: selection, inSection: 0),
                                  animated: false,
                            scrollPosition: .None)
      MSLogDebug("selecting cell for item \(selection) with label '\(labels[item]) where offset = \(offset)")
      collectionView.setContentOffset(offset, animated: animated)
    } else {
      MSLogDebug("could not get an offset for item \(item), invalidating layout …")
      layout.invalidateLayout()
    }
  }

  public override func layoutSubviews() {
//    MSLogDebug("")
    super.layoutSubviews()
    if selection > -1 { selectItem(selection, animated: false) }
  }

  public var labels: [String] = [] { didSet { reloadData() } }
  public var didSelectItem: ((InlinePickerView, Int) -> Void)?

  public var font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody) //{
//    didSet {
//      (collectionView.visibleCells() as? [InlinePickerViewCell])?.apply {
//        [unowned font = self.font] in
//        if let text = $0.text { $0.text = text | font }
//      }
//      if   font.pointSize > selectedFont.pointSize
//        || (oldValue.pointSize > selectedFont.pointSize && oldValue.pointSize > font.pointSize)
//      {
//        reloadData()
//      }
//    }
//  }

  public var textColor = UIColor.darkTextColor() //{
//    didSet {
//      (collectionView.visibleCells() as? [InlinePickerViewCell])?.apply {
//        [unowned textColor = self.textColor] in
//        if let text = $0.text { $0.text = text | textColor }
//      }
//    }
//  }
  public var selectedFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody) //{
//    didSet {
//      (collectionView.visibleCells() as? [InlinePickerViewCell])?.apply {
//        [unowned selectedFont = self.selectedFont] in
//        if let selectedText = $0.selectedText { $0.selectedText = selectedText | selectedFont }
//      }
//      if    selectedFont.pointSize > font.pointSize
//        || (oldValue.pointSize > font.pointSize && oldValue.pointSize > selectedFont.pointSize)
//      {
//        reloadData()
//      }
//    }
//  }

  public var selectedTextColor = UIColor.darkTextColor() //{
//    didSet {
//      (collectionView.visibleCells() as? [InlinePickerViewCell])?.apply {
//        [unowned selectedTextColor = self.selectedTextColor] in
//        if let selectedText = $0.selectedText { $0.selectedText = selectedText | selectedTextColor }
//      }
//    }
//  }

  public func reloadData() {
//    MSLogDebug("")
    layout.invalidateLayout()
    setNeedsLayout()
    collectionView.setNeedsLayout()
    collectionView.reloadData()
    collectionView.layoutIfNeeded()
    layoutIfNeeded()
//    if selection > -1 { selectItem(selection, animated: false) }
  }

  public var itemHeight: CGFloat { return ceil(max(font.lineHeight, selectedFont.lineHeight)) * 2 }
  public var itemPadding: CGFloat = 8.0 { didSet { reloadData() } }
  public var usePerspective = false

  var itemWidths: [CGFloat] { return labels.map {[a = [NSFontAttributeName:font]] in ceil($0.sizeWithAttributes(a).width)} }

  var selection: Int = -1

  public var selectedItemFrame: CGRect? {
    if selection > -1,
      let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: selection, inSection: 0)) where cell.selected
    {
      var frame = cell.frame
      frame.origin = frame.origin - collectionView.contentOffset
      return frame
    } else { return nil }
  }

  public var editing = false {
    didSet {
//      MSLogDebug("edting = \(editing)")
//      layout.invalidateLayout()
//      setNeedsLayout()
//      layoutIfNeeded()
      collectionView.scrollEnabled = editing
      reloadData()
    }
  }
}

// MARK: - UICollectionViewDataSource
extension InlinePickerView: UICollectionViewDataSource {


  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return labels.count }

  public func collectionView(collectionView: UICollectionView,
      cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
  {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! InlinePickerViewCell
    let text = labels[indexPath.item]
    cell.text = text ¶| [font, textColor]
    cell.selectedText = text ¶| [selectedFont, selectedTextColor]
//    MSLogDebug("cell = \(cell.description)")
    return cell
  }
}

// MARK: - UICollectionViewDelegate
extension InlinePickerView: UICollectionViewDelegate {

  /**
  collectionView:shouldSelectItemAtIndexPath:

  - parameter collectionView: UICollectionView
  - parameter indexPath: NSIndexPath

  - returns: Bool
  */
  public func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
  }

  /**
  collectionView:shouldDeselectItemAtIndexPath:

  - parameter collectionView: UICollectionView
  - parameter indexPath: NSIndexPath

  - returns: Bool
  */
  public func collectionView(collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
  }

  /**
  collectionView:didSelectItemAtIndexPath:

  - parameter collectionView: UICollectionView
  - parameter indexPath: NSIndexPath
  */
  public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    MSLogDebug("")
    didSelectItem?(self, indexPath.item)
  }

  /**
  collectionView:willDisplayCell:forItemAtIndexPath:

  - parameter collectionView: UICollectionView
  - parameter cell: UICollectionViewCell
  - parameter indexPath: NSIndexPath
  */
  public func collectionView(collectionView: UICollectionView,
             willDisplayCell cell: UICollectionViewCell,
          forItemAtIndexPath indexPath: NSIndexPath)
  {
    if indexPath.item == selection { cell.selected = true }
    if editing && cell.hidden { cell.hidden = false }
  }
}

extension InlinePickerView: UIScrollViewDelegate {
  /**
  scrollViewDidEndDecelerating:

  - parameter scrollView: UIScrollView
  */
  public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//    MSLogDebug("")
    guard let item = collectionView.indexPathsForSelectedItems()?.first?.item else {
      MSLogWarn("failed to get index path for selected cell")
      return
    }
    // invoke selection handler
    didSelectItem?(self, item)
  }
  /**
  scrollViewWillEndDragging:withVelocity:targetContentOffset:

  - parameter scrollView: UIScrollView
  - parameter velocity: CGPoint
  - parameter targetContentOffset: UnsafeMutablePointer<CGPoint>
  */
  public func scrollViewWillEndDragging(scrollView: UIScrollView,
                          withVelocity velocity: CGPoint,
                   targetContentOffset: UnsafeMutablePointer<CGPoint>)
  {
    let offset = targetContentOffset.memory
    guard let item = (collectionView.collectionViewLayout as! InlinePickerViewLayout).indexOfItemAtOffset(offset) else {
      MSLogWarn("failed to get index path for cell at point \(offset)")
      return
    }
    // update selection
    MSLogDebug("selecting cell for item \(selection) with label '\(labels[item]) where offset = \(offset)")
    selection = item
    collectionView.selectItemAtIndexPath(NSIndexPath(forItem: item, inSection: 0), animated: false, scrollPosition:.None)
  }
}