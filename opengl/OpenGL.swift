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

struct Vertex {
  var position:(Float,Float,Float)
  var color:(Float,Float,Float,Float)
}

extension GLKMatrix4 {
  var array: [Float] {
    return (0..<16).map { i in
      self[i]
    }
  }
}

class OpenGL:UIView {

  var colorRenderBuffer = GLuint()
  var colorSlot:GLuint!
  var displayLink:CADisplayLink!
  var modelViewUniform:GLuint!
  var positionSlot:GLuint!
  var projectionUniform:GLuint!
  
  let vertices = [
    Vertex(position:(1,-1,0),color:(1,0,0,1)),
    Vertex(position:(1,1,0),color:(0,1,0,1)),
    Vertex(position:(-1,1,0),color:(0,0,1,1)),
    Vertex(position:(-1,-1,0),color:(0,0,0,1))
  ]
  
  let indices:[GLubyte] = [
    0,1,2,
    2,3,0
  ]

  
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
    
    setupDisplayLink()
    setupBuffers()
    compileShaders()
    setupVertexBufferObjects()

  }
  
  func render(_ link:CADisplayLink) {
    glClearColor(0, 104/255.0, 55.0/255.0, 1.0)
    glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    
    let projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65), 0.5, 0.1, 100.0)
    glUniformMatrix4fv(GLint(projectionUniform), 1, 0,projection.array)
    
    let modelview = GLKMatrix4MakeTranslation(GLfloat(sin(CACurrentMediaTime())), 0, -7)
    glUniformMatrix4fv(GLint(modelViewUniform), 1, 0, modelview.array)
    
    glViewport(0, 0, GLsizei(frame.width), GLsizei(frame.height))
    
    let size = GLsizei(MemoryLayout<Vertex>.size)
    glVertexAttribPointer(positionSlot, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), size,UnsafePointer<Int>(bitPattern:0))
    glVertexAttribPointer(colorSlot, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), size, UnsafePointer<Int>(bitPattern:MemoryLayout<Float>.size * 3))
   
    let vertexBufferOffset = UnsafeMutableRawPointer(bitPattern: 0)
    glDrawElements(GLenum(GL_TRIANGLES), GLsizei((indices.count * MemoryLayout<GLubyte>.size)/MemoryLayout<GLubyte>.size),GLenum(GL_UNSIGNED_BYTE), vertexBufferOffset)
    
    context.presentRenderbuffer(Int(GL_RENDERBUFFER))
  }
  
  // MARK: - Rendering timer
  private func setupDisplayLink() {
    displayLink = CADisplayLink(target: self, selector: #selector(render(_:)))
    displayLink.add(to: RunLoop.current, forMode:.defaultRunLoopMode)
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
  
  private func setupVertexBufferObjects() {
    var vertexBuffer = GLuint()
    glGenBuffers(1, &vertexBuffer)
    glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
    glBufferData(GLenum(GL_ARRAY_BUFFER), (vertices.count * MemoryLayout<Vertex>.size), vertices, GLenum(GL_STATIC_DRAW))
    
    var indexBuffer = GLuint()
    glGenBuffers(1, &indexBuffer)
    glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer)
    glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), (indices.count * MemoryLayout<GLubyte>.size), indices, GLenum(GL_STATIC_DRAW))
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
    
    projectionUniform = GLuint(glGetUniformLocation(programHandle, "Projection"))
    modelViewUniform = GLuint(glGetUniformLocation(programHandle, "Modelview"))
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
