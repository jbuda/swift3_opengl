//
//  OpenGLView.swift
//  opengl
//
//  Created by Janusz on 15/02/2017.
//  Copyright © 2017 gfm. All rights reserved.
//

import UIKit
import CoreMotion

class OpenGLView:UIView {

  lazy var context:EAGLContext = { return EAGLContext(api: .openGLES3) }()
  
  lazy var motionManager:CMMotionManager = {
    let manager = CMMotionManager()
    manager.deviceMotionUpdateInterval = 0.05
    
    return manager
  }()
  
  var scene:Scene!
  
  override class var layerClass:AnyClass {
    get {
      return CAEAGLLayer.self
    }
  }
  
  required init?(coder aDecoder:NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(frame:CGRect) {
    super.init(frame: frame)
    
    EAGLContext.setCurrent(context)
    
    setup()
  }
}

extension OpenGLView {
  
  fileprivate func setup() {
    scene = Scene(BufferParams(size:frame.size,ctx:context,layer:layer as! CAEAGLLayer))
    
    if let _ = scene.program {
      startMotion()
    }
  }
  
  fileprivate func startMotion() {
    
    if motionManager.isDeviceMotionAvailable {
     
      motionManager.startDeviceMotionUpdates(to: OperationQueue.current!) { data,error in
        guard let data = data else { return }
        
        self.scene.render(DeviceRotation(origin:self.motionManager.deviceMotion!.attitude,current:data.attitude))
      }
    }
  }
  
}
