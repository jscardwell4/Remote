//
//  ViewController.swift
//  NetworkingISYApp
//
//  Created by Jason Cardwell on 8/3/15.
//  Copyright © 2015 Moondeer Studios. All rights reserved.
//

import UIKit
import MoonKit
import Networking

class ViewController: UIViewController, GCDAsyncUdpSocketDelegate {

  let socket = GCDAsyncUdpSocket()

  @IBOutlet weak var messageText: UITextView!
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    socket.setDelegate(self)
    socket.setDelegateQueue(dispatch_get_main_queue())
    do {
      try socket.bindToPort(1900)
      print("bound to port")
      try socket.joinMulticastGroup("239.255.255.250")
      print("joined group")
      try socket.beginReceiving()
      print("listening")
    } catch { print(error) }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @objc func udpSocket(sock: GCDAsyncUdpSocket,
    didReceiveData data: NSData,
    fromAddress address: NSData,
    withFilterContext filterContext: AnyObject)
  {
    print("data received")
    guard let dataString = String(data: data) else { return }
    print(dataString)
    messageText.text = dataString
  }

}

