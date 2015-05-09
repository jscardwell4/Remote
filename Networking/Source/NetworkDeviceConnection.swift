//
//  NetworkDeviceConnection.swift
//  Remote
//
//  Created by Jason Cardwell on 5/05/15.
//  Copyright (c) 2014 Moondeer Studios. All rights reserved.
//

import Foundation
import MoonKit
import DataModel

@objc class NetworkDeviceConnection {

  typealias Error = ConnectionManager.Error

  private var sourcesRegistered = 0
  private var messageQueue = Queue<MessageQueueEntry>()
  private let dataCallback: ((String) -> Void)?
  private var connectCallback: ConnectionManager.Callback?
  private var disconnectCallback: ConnectionManager.Callback?

  private(set) var readSource: dispatch_source_t?
  private(set) var writeSource: dispatch_source_t?
  private(set) var connecting = false

  var connected: Bool {
    return    readSource != nil  && dispatch_source_testcancel(readSource!) == 0
           && writeSource != nil && dispatch_source_testcancel(writeSource!) == 0
  }


  /**
  init:

  :param: c ((String) -> Void
  */
  init(callback: ((String) -> Void)? = nil) { dataCallback = callback }

  /**
  Method for establishing a connection to `device` with an optional callback

  :param: completion ((Bool, NSError?) -> Void)? = nil
  */
  func connect(completion: ((Bool, NSError?) -> Void)? = nil) {

    // Exit early if an attempt to connect is already in progress
    if connecting {
      MSLogWarn("already trying to establish a connection with device")
      completion?(false, Error.ConnectionInProgress.error())
    }

    // Or if we are already connected
    else if connected {
      MSLogWarn("already connected to device")
      completion?(false, Error.ConnectionExists.error())
    }

    // Otherwise set the flag and continue
    else {
      connecting = true
      connectCallback = completion


      // Get file descriptors and queues for sources
      let sourceDescriptor = sourceFileDescriptor

      if sourceDescriptor >= 0 {

        if let readQueue = NetworkDeviceConnection.readSourceQueue {

          readSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ,  UInt(sourceFileDescriptor), 0, readQueue)
          assert(readSource != nil)

          dispatch_source_set_event_handler(readSource!, readEventHandler)
          dispatch_source_set_cancel_handler(readSource!, readCancelHandler)
          dispatch_source_set_registration_handler(readSource!, readRegistrationHandler)
          dispatch_resume(readSource!)

        }

        if let writeQueue = NetworkDeviceConnection.writeSourceQueue {

          writeSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ,  UInt(sourceFileDescriptor), 0, writeQueue)
          assert(writeSource != nil)

          dispatch_source_set_event_handler(writeSource!, writeEventHandler)
          dispatch_source_set_cancel_handler(writeSource!, writeCancelHandler)
          dispatch_source_set_registration_handler(writeSource!, writeRegistrationHandler)
          dispatch_resume(writeSource!)
        }
        
      }
    }

  }

  var sourceFileDescriptor: dispatch_fd_t { return -1 }

  static let readSourceQueue  = dispatch_queue_create("com.moondeerstudios.receive", DISPATCH_QUEUE_CONCURRENT)
  static let writeSourceQueue = dispatch_queue_create("com.moondeerstudios.send", DISPATCH_QUEUE_CONCURRENT)


  var readEventHandler: dispatch_block_t {
    return { [unowned self] in
      if self.readSource == nil { return }
      let bytesAvailable = dispatch_source_get_data(self.readSource!)
      MSLogDebug("bytes available = \(bytesAvailable)")
      var msg = UnsafeMutablePointer<Int8>.alloc(Int(bytesAvailable) + 1)
      let handle = Int32(dispatch_source_get_handle(self.readSource!))
      MSLogDebug("sourceFileDescriptor = \(self.sourceFileDescriptor), handle = \(handle), msg = \(msg)")
      let bytesRead = read(handle, msg, Int(bytesAvailable))
      MSLogDebug("bytesRead = \(bytesRead)")
      if bytesRead < 0 {
        MSLogError("read failed for socket: \(errno) - \(toString(String.fromCString(strerror(errno))))")
        dispatch_source_cancel(self.readSource!)
      } else if let message = String(CString: msg, encoding: NSUTF8StringEncoding) {
        NSOperationQueue.mainQueue().addOperationWithBlock { self.dataCallback?(message) }
      }
    }
  }

  var writeEventHandler: dispatch_block_t {
    return { [unowned self] in

      if let entry = self.messageQueue.dequeue() where !entry.message.isEmpty {
        assert(self.writeSource != nil)
        var success = true
        var error: NSError?

        entry.message.withCString({
          (msg: UnsafePointer<Int8>) -> Void in

          let bytesWritten = write(Int32(dispatch_source_get_handle(self.writeSource!)), msg, count(entry.message.utf8))

          // Check if string was written
          if bytesWritten < 0 {
            MSLogError("write failed for socket: \(errno) - \(toString(String.fromCString(strerror(errno))))")
            success = false
            error = NSError(domain: NSPOSIXErrorDomain, code: Int(errno), userInfo: nil)

            dispatch_source_cancel(self.writeSource!)
          }
        })

        entry.completion?(success, nil, error)
      }

    }
  }

  /** Should only be called from cancel handlers */
  private func disconnectHandlerCallback() {
    var error: NSError? = errno != 0 ? NSError(domain: NSPOSIXErrorDomain, code: Int(errno), userInfo: nil) : nil
    self.disconnectCallback?(true, error)
  }

  var readCancelHandler: dispatch_block_t {
    return { [unowned self] in
      assert(self.readSource != nil)
      NSOperationQueue.mainQueue().addOperationWithBlock { [unowned self] in
        self.sourcesRegistered--
        close(Int32(dispatch_source_get_handle(self.readSource!)))
        self.readSource = nil
        if let w = self.writeSource where dispatch_source_testcancel(w) == 0 { dispatch_source_cancel(w) }
        else { self.disconnectHandlerCallback() }
      }
    }
  }

  var writeCancelHandler: dispatch_block_t {
    return { [unowned self] in
      assert(self.writeSource != nil)
      NSOperationQueue.mainQueue().addOperationWithBlock { [unowned self] in
        self.sourcesRegistered--
        close(Int32(dispatch_source_get_handle(self.writeSource!)))
        self.writeSource = nil
        if let r = self.readSource where dispatch_source_testcancel(r) == 0 { dispatch_source_cancel(r) }
        else { self.disconnectHandlerCallback() }
      }
    }
  }

  /** Should only be called from registration handlers to invoke connection callbacks if appropriate */
  private func registrationHandlerCallback() {
    if sourcesRegistered == 2 {
      connecting = false
      NSOperationQueue.mainQueue().addOperationWithBlock { [unowned self] in
        self.connectCallback?(true, nil)
      }
    }
  }

  var readRegistrationHandler: dispatch_block_t {
    return { [unowned self] in self.sourcesRegistered++; self.registrationHandlerCallback() }
  }

  var writeRegistrationHandler: dispatch_block_t {
    return { [unowned self] in self.sourcesRegistered++; self.registrationHandlerCallback() }
  }

  /**
  Method for disconnecting from the device with an optional callback

  :param: completion ((Bool, NSError?) -> Void)? = nil
  */
  func disconnect(completion: ((Bool, NSError?) -> Void)? = nil) {
    disconnectCallback = completion
    if let r = self.readSource where dispatch_source_testcancel(r) == 0 { dispatch_source_cancel(r) }
    if let w = self.writeSource where dispatch_source_testcancel(w) == 0 { dispatch_source_cancel(w) }
  }

}