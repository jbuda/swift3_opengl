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
  var colorSlot = GLuint()
  var positionSlot = GLuint()
  
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
    compileShaders()
    
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

extension OpenGL {
  
  fileprivate func compileShaders() {
    
    guard let vertex = compileShader(shader: "SimpleVertex", with: GLenum(GL_VERTEX_SHADER)), let fragment = compileShader(shader: "SimpleFragment", with: GLenum(GL_FRAGMENT_SHADER)) else {
      print("Error with shaders")
      return
    }
    
    let programHandle = glCreateProgram()
    glAttachShader(programHandle, vertex)
    glAttachShader(programHandle, fragment)
    glLinkProgram(programHandle)
    
    var success = GLint()
    glGetProgramiv(programHandle, GLenum(GL_LINK_STATUS), &success)
    
    if success == GL_FALSE {
      print("Something when wrong")
    }
    
    glUseProgram(programHandle)
    
    positionSlot = GLuint(glGetAttribLocation(programHandle, "Position"))
    colorSlot = GLuint(glGetAttribLocation(programHandle, "SourceColor"))
    glEnableVertexAttribArray(positionSlot)
    glEnableVertexAttribArray(colorSlot)
  }
  
  fileprivate func compileShader(shader name:String,with type:GLenum)->GLuint? {
  
    guard let shaderPath = Bundle.main.path(forResource: name, ofType: "glsl", inDirectory:"shaders/",forLocalization:nil) else {
      print("Error! \(name) not found")
      return nil
    }
    
    do {
      let shaderString = try String(contentsOfFile: shaderPath, encoding: .utf8)
      var shaderStringUTF8 = UnsafePointer<GLchar>(shaderString.cString(using: .utf8))
      
      let shaderHandle = glCreateShader(type)
      var shaderStringLength = GLint(shaderString.characters.count)
      
      glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength)
      
      glCompileShader(shaderHandle)
      
      var success = GLint()
      glGetShaderiv(shaderHandle, GLenum(GL_COMPILE_STATUS), &success)
      
      if success == GL_FALSE {
        let infoLog = UnsafeMutablePointer<GLchar>.allocate(capacity: 256)
        var infoLogLength = GLsizei()
      
        glGetShaderInfoLog(shaderHandle, GLsizei(MemoryLayout<GLchar>.size * 256), &infoLogLength, infoLog)
        print("compileShader() : glCompileShader failed:",String(cString: infoLog))
        
        infoLog.deallocate(capacity: 256)
        exit(1)
      }
      
      return shaderHandle
      
    } catch {
      print("Error! \(error.localizedDescription)")
    }
    
    return nil
  }
}
