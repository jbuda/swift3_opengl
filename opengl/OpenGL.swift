//
//  OpenGL.swift
//  opengl
//
//  Created by Janusz on 01/02/2017.
//  Copyright © 2017 gfm. All rights reserved.
//

import UIKit
import OpenGLES
import GLKit

class OpenGL:UIView {

  var colorRenderBuffer = GLuint()
  
  override class var layerClass:AnyClass {
    get {
      return CAEAGLLayer.self
    }
  }
  
  lazy var context:EAGLContext = {
    return EAGLContext(api: .openGLES2)
  }()
  
  lazy var eaglLayer:CAEAGLLayer = {
    return self.layer as! CAEAGLLayer
  }()
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(frame: CGRect) {
    super.init(frame:frame)
    
    EAGLContext.setCurrent(context)
    
    setupBuffers()
    render()
  }
  
  private func render() {
    glClearColor(0, 104/255.0, 55.0/255.0, 1.0)
    glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    
    context.presentRenderbuffer(Int(GL_RENDERBUFFER))
  }
  
  // MARK: - Setup OpenGL view
  private func setupBuffers() {
    
    glGenRenderbuffers(1, &colorRenderBuffer)
    glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderBuffer)
    
    context.renderbufferStorage(Int(GL_RENDERBUFFER), from: eaglLayer)
    
    var frameBuffer = GLuint()
    
    glGenFramebuffers(1, &frameBuffer)
    glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
    glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), colorRenderBuffer)
  }
}
