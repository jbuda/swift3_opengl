//
//  OpenGLView.swift
//  opengl
//
//  Created by Janusz on 15/02/2017.
//  Copyright © 2017 gfm. All rights reserved.
//

import UIKit

class OpenGLView:UIView {

  var buffers:Buffers!
  lazy var context:EAGLContext = { return EAGLContext(api: .openGLES3) }()
  var renderer:Renderer!
  var shaders:Shaders!
  
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
    buffers = Buffers(frame.size,context,layer as! CAEAGLLayer)
    
    shaders = Shaders()
    
    renderer = Renderer(frame.size,context,layer as! CAEAGLLayer,shaders.modelViewUniform,shaders.projectionUniform,shaders.colorSlot,shaders.positionSlot,buffers.indices)
  }
  
}
