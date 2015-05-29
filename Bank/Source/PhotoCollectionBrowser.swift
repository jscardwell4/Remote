//
//  PhotoCollectionBrowser.swift
//  Remote
//
//  Created by Jason Cardwell on 5/23/15.
//  Copyright (c) 2015 Moondeer Studios. All rights reserved.
//

import UIKit
import Photos
import MoonKit

// TODO: Add selection callback or delegate protocol
// TODO: Remember previously used item scale

private let reuseIdentifier = "Cell"
private let imageViewNametag = "image"

class PhotoCollectionBrowser: UIViewController, PhotoCollectionLayoutDelegate, UICollectionViewDataSource {

  typealias ImageSelection = (data: NSData, uti: String, orientation: UIImageOrientation)

  let callback: (PhotoCollectionBrowser, ImageSelection?) -> Void
  private(set) var cancelled = false

  // MARK: - Data properties

  /** The `PHAsset` objects fetched from the `PHAssetCollection` passed to `initWithCollection:` */
  let assets: [PHAsset]

  /** Holds the currently selected asset, if any */
  private var selectedAsset: PHAsset?

  /** Property of  convenience */
  private let manager = PHCachingImageManager()

  // MARK: - UI properties

  /** The collection view */
  @IBOutlet var collectionView: UICollectionView!

  /** The collection view layout */
  @IBOutlet var layout: PhotoCollectionLayout!

  // MARK: - Manipulating the scale of the image

  typealias ItemScale = PhotoCollectionLayout.ItemScale

  /** The current scale for items */
  private var itemScale: ItemScale = .EightAcross {
    didSet {
      layout.itemScale = itemScale
      if oldValue != itemScale {
        stopCachingForScale(oldValue, aspect: aspect)
        startCachingForScale(itemScale, aspect: aspect)
        requestImagesForVisibleCells()
      }
    }
  }

  /** Bottom toolbar item for manipulating the currently used image scale */
  @IBOutlet weak var scaleSlider: UISlider!

  /**
  Scales from 8 cells across to just 1 cell across

  :param: sender UISlider
  */
  @IBAction func updateScale(sender: UISlider) { itemScale = ItemScale(rawValue: sender.value) }

  // MARK: - Caching

  private struct CacheType: Hashable { let scale: ItemScale; let aspect: Aspect; var hashValue: Int { return 0 } }

  /**
  startCachingForScale:mode:

  :param: scale ItemScale
  */
  private func startCachingForScale(scale: ItemScale, aspect: Aspect) {
    MSLogDebug("starting to cache images for item scale '\(scale)'")
    caches.insert(CacheType(scale: scale, aspect: aspect))
    manager.startCachingImagesForAssets(assets, targetSize: scale.itemSize, contentMode: aspect.contentMode, options: nil)
  }

  /**
  stopCachingForScale:mode:

  :param: scale ItemScale
  */
  private func stopCachingForScale(scale: ItemScale, aspect: Aspect) {
    MSLogDebug("no longer caching images for item scale '\(scale)'")
    caches.remove(CacheType(scale: scale, aspect: aspect))
    manager.stopCachingImagesForAssets(assets, targetSize: scale.itemSize, contentMode: .AspectFill, options: nil)
  }

  // MARK: - Manipulating the aspect ratio used to display images

  enum Aspect: Int { case Fill, Fit; var contentMode: PHImageContentMode { return self == .Fill ? .AspectFill : .AspectFit } }

  /** Aspect to use for new image requests, this is ignored for a request servicing a 'zoomed' cell */
  private var aspect = Aspect.Fill {
    didSet {
      if oldValue != aspect {
        stopCachingForScale(itemScale, aspect: oldValue)
        startCachingForScale(itemScale, aspect: aspect)
        requestImagesForVisibleCells()
      }
    }
  }

  /** Bottom toolbar item for manipulating the currently used aspect */
  @IBOutlet weak var aspectControl: ToggleImageSegmentedControl!
  

  // MARK: - Asset image requests

  /** Holds IDs of outstanding `PHImageManager` requests */
  private var requests: Set<PHImageRequestID> = []

  /** Holds the scales currently being cached by the image manager */
  private var caches: Set<CacheType> = []

  /** requestImagesForVisibleCells */
  private func requestImagesForVisibleCells() {
    let indexPaths = collectionView.indexPathsForVisibleItems() as! [NSIndexPath]
    MSLogDebug("requesting images for cells: \(indexPaths.map({$0.row}))")
    apply(indexPaths){self.requestImageAtIndexPath($0)}
  }

  typealias RequestResult = (image: UIImage!, info: [NSObject:AnyObject]!)

  /**
  Request the image for the asset at the specified index for the specified cell

  :param: index Int
  :param: size CGSize
  :param: mode PHImageContentMode
  */
  private func requestImageAtIndexPath(indexPath: NSIndexPath) {
    precondition(indexPath.row < assets.count, "index out of range")

    let asset = assets[indexPath.row]

    let mode: PHImageContentMode
    let size: CGSize

    if indexPath == layout.zoomedItem { size = sizeForZoomedItemAtIndexPath(indexPath); mode = .AspectFit }
    else { size = layout.itemScale.itemSize; mode = aspect.contentMode }

    let handler: (UIImage!, [NSObject:AnyObject]!) -> Void = { [weak self] in
      self?.handleRequestResult((image: $0, info: $1), forIndexPath: indexPath, contentMode: mode)
    }

    requests.insert(manager.requestImageForAsset(asset, targetSize: size, contentMode: mode, options: nil, resultHandler: handler))
  }

  /**
  A handler for `PHImageManager` request result. Updates cell's image view's image, logs cancellation, or handles error.

  :param: result RequestResult
  :param: indexPath NSIndexPath
  */
  private func handleRequestResult(result: RequestResult, forIndexPath indexPath: NSIndexPath, contentMode: PHImageContentMode) {

    let id = (result.info[PHImageResultRequestIDKey] as! NSNumber).intValue

    if result.info[PHImageCancelledKey] as? Bool == true { MSLogDebug("request with id \(id) cancelled"); requests.remove(id) }

    else if let error = result.info[PHImageErrorKey] as? NSError {
      MSHandleError(error, message: "problem encountered loading image with request id \(id)")
      requests.remove(id)
    }

    else if let image = result.image {
      if let imageView = collectionView.cellForItemAtIndexPath(indexPath)?.contentView[imageViewNametag] as? UIImageView {
        imageView.image = image
        imageView.contentMode = contentMode == .AspectFit ? .ScaleAspectFit : .ScaleAspectFill
      }

      if result.info[PHImageResultIsDegradedKey] as? Bool != true { requests.remove(id) }
    }
  }

  // MARK: - Select and cancel actions

  /** Dismiss the controller */
  @IBAction func cancel() { cancelled = true; callback(self, nil) }

  /** Right toolbar button for the top toolbar */
  @IBOutlet weak var selectButton: UIBarButtonItem!

  /** Selects the zoomed item */
  @IBAction func select() {
    if let asset = selectedAsset {
      manager.requestImageDataForAsset(asset, options: nil) {[unowned self]
        (data:NSData!, uti:String!, orientation:UIImageOrientation, info:[NSObject : AnyObject]!) -> Void in
        if let error = info[PHImageErrorKey] as? NSError { MSHandleError(error); self.cancel() }
        else { self.callback(self, (data: data, uti: uti, orientation: orientation)) }
      }
    }
  }

  // MARK: - Initialization

  /**
  initWithCollection:

  :param: collection PHAssetCollection
  */
  init(collection: PHAssetCollection, callback c: (PhotoCollectionBrowser, ImageSelection?) -> Void) {
    callback = c
    let fetchResult = PHAsset.fetchAssetsInAssetCollection(collection, options: nil)
    assets = fetchResult.objectsAtIndexes(NSIndexSet(range: 0 ..< fetchResult.count)) as! [PHAsset]
    super.init(nibName: "PhotoCollectionBrowser", bundle: Bank.bundle)
  }

  /**
  init:

  :param: aDecoder NSCoder
  */
  required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  // MARK: - View management

  override func viewDidLoad() {
    super.viewDidLoad()

    aspectControl.setImage(Bank.bankImageNamed("aspect-fill")!,
             selectedImage: Bank.bankImageNamed("aspect-fill-selected")!,
         forSegmentAtIndex: 0)
    aspectControl.setImage(Bank.bankImageNamed("aspect-fit")!,
             selectedImage: Bank.bankImageNamed("aspect-fit-selected")!,
         forSegmentAtIndex: 1)
    aspectControl.selectedSegmentIndex = aspect.rawValue
    aspectControl.toggleAction = {[unowned self]
      control in

        MSLogDebug("aspect change muthafucka!!!")
        self.aspect = Aspect(rawValue: control.selectedSegmentIndex)!
    }

    scaleSlider.minimumValue = ItemScale.minScale.normalized
    scaleSlider.maximumValue = ItemScale.maxScale.normalized
    scaleSlider.value = itemScale.normalized

    layout.itemScale = itemScale

    // Register cell classes
    collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

  }

  /**
  Begin caching for current scale and aspect

  :param: animated Bool
  */
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    startCachingForScale(itemScale, aspect: aspect)
  }

  /**
  Stop all image requests and stop all caching

  :param: animated Bool
  */
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    apply(requests){[manager = self.manager] in manager.cancelImageRequest($0)}
    manager.stopCachingImagesForAllAssets()
  }


  // MARK: - UICollectionViewDataSource

  /**
  numberOfSectionsInCollectionView:

  :param: collectionView UICollectionView

  :returns: Int
  */
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int { return 1 }


  /**
  collectionView:numberOfItemsInSection:

  :param: collectionView UICollectionView
  :param: section Int

  :returns: Int
  */
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return assets.count }

  /**
  collectionView:cellForItemAtIndexPath:

  :param: collectionView UICollectionView
  :param: indexPath NSIndexPath

  :returns: UICollectionViewCell
  */
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier,
                                                        forIndexPath: indexPath) as! UICollectionViewCell

    // decorate cell

    if let imageView = cell.contentView.subviewWithNametag(imageViewNametag) as? UIImageView {
      imageView.image = nil
    } else {
      cell.backgroundColor = UIColor.clearColor()
      cell.opaque = false
      cell.contentView.backgroundColor = UIColor.clearColor()
      cell.contentView.opaque = false

      let imageView = UIImageView(autolayout: true)
      imageView.nametag = imageViewNametag
      imageView.contentMode = .ScaleAspectFill
      imageView.clipsToBounds = true
      imageView.backgroundColor = UIColor.clearColor()
      imageView.opaque = false
      cell.contentView.addSubview(imageView)
      cell.contentView.constrain(𝗩|imageView|𝗩, 𝗛|imageView|𝗛)
    }

    // request image for cell

    requestImageAtIndexPath(indexPath)

    return cell
  }

  // MARK: - UICollectionViewDelegate

  /**
  collectionView:didSelectItemAtIndexPath:

  :param: collectionView UICollectionView
  :param: indexPath NSIndexPath
  */
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    assert(collectionView.cellForItemAtIndexPath(indexPath)?.selected == true)
    if layout.zoomedItem != nil { selectedAsset = nil; layout.zoomedItem = nil }
    else { selectedAsset = assets[indexPath.row]; layout.zoomedItem = indexPath; requestImageAtIndexPath(indexPath) }
    selectButton.enabled = layout.zoomedItem != nil
  }

  // MARK: - PhotoCollectionLayoutDelegate

  /**
  sizeForZoomedItemInCollectionView:layout:

  :param: collectionView UICollectionView
  :param: layout PhotoCollectionLayout

  :returns: CGSize
  */
  func sizeForZoomedItemAtIndexPath(indexPath: NSIndexPath) -> CGSize {
    let ratio = Ratio(assets[indexPath.row].pixelWidth, assets[indexPath.row].pixelHeight)
    let width  = min(ratio.numerator, ItemScale.maxScale.itemSize.width)
    let height = ratio.denominatorForNumerator(width)
    return CGSize(width: width, height: height)
  }

}

private func ==(lhs: PhotoCollectionBrowser.CacheType, rhs: PhotoCollectionBrowser.CacheType) -> Bool {
  return lhs.scale == rhs.scale && lhs.aspect == rhs.aspect
}