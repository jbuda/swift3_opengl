//
//  OpenGLView.swift
//  opengl
//
//  Created by Janusz on 15/02/2017.
//  Copyright © 2017 gfm. All rights reserved.
//

import UIKit

class OpenGLView:UIView {

  lazy var context:EAGLContext = { return EAGLContext(api: .openGLES3) }()
  
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
  }
  
}
