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
import CoreMotion

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
  var currentRotation:Float = 0
  var depthRenderBuffer:GLuint = GLuint()
  var displayLink:CADisplayLink!
  var modelViewUniform:GLuint!
  var positionSlot:GLuint!
  var projectionUniform:GLuint!
  
  let vertices = [
    Vertex(position:(1,-1,1),color:(1,0,0,1)),
    Vertex(position:(1,1,1),color:(0,1,0,1)),
    Vertex(position:(-1,1,1),color:(0,0,1,1)),
    Vertex(position:(-1,-1,1),color:(0,0,0,1)),
    Vertex(position:(1,-1,-1),color:(1,0,0,1)),
    Vertex(position:(1,1,-1),color:(1,0,0,1)),
    Vertex(position:(-1,1,-1),color:(0,1,0,1)),
    Vertex(position:(-1,-1,-1),color:(0,1,0,1))
  ]
  
  let indices:[GLubyte] = [
    0,1,2,
    2,3,0,
    4,5,6,
    4,7,6,
    2,7,3,
    7,6,2,
    0,4,1,
    4,1,5,
    6,2,1,
    1,6,5,
    0,3,7,
    0,7,4
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
  
  lazy var motionManager:CMMotionManager = {
    let manager = CMMotionManager()
    manager.deviceMotionUpdateInterval = 0.05
    
    return manager
  }()
  
  var zeroPoint:CMAttitude?
  var quaterionRotation:GLKMatrix4!
  var rotation:CMRotationMatrix?
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(frame: CGRect) {
    super.init(frame:frame)
    
    EAGLContext.setCurrent(context)
    
    //setupDisplayLink()
    setupBuffers()
    compileShaders()
    setupVertexBufferObjects()
    
    if motionManager.isDeviceMotionAvailable {
      
      motionManager.startDeviceMotionUpdates(to: OperationQueue.current!) { data,error in
        guard let data = data else { return }

        self.zeroPoint = self.zeroPoint ?? self.motionManager.deviceMotion!.attitude
        
        data.attitude.multiply(byInverseOf: self.zeroPoint!)

        let quat = data.attitude.quaternion
        
        var quatX = quat.x
        var quatY = quat.y
        
        if quatX >= 0.2 {
          quatX = 0.2
        } else if quatX <= -0.2 {
          quatX = -0.2
        }
      
        if quatY >= 0.2 {
          quatY = 0.2
        } else if quatY <= -0.2 {
            quatY = -0.2
        }
        
        let q = GLKQuaternionMake(Float(quatX), Float(quatY), 0.0, Float(quat.w))

        
        //self.rotation = data.attitude.rotationMatrix
        self.quaterionRotation = GLKMatrix4MakeWithQuaternion(q)
        
        self.render(nil)
      }
      
    }
    
  }
  
  func render(_ link:CADisplayLink?) {
    glClearColor(0, 104/255.0, 55.0/255.0, 1.0)
    glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
    glEnable(GLenum(GL_DEPTH_TEST))
    
    let projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), 0.5, 0.1, 10)

    
    glUniformMatrix4fv(GLint(projectionUniform), 1, 0,projection.array)
    
    var modelview = GLKMatrix4MakeTranslation(0, 0, -7)
    
    if let r = rotation {
 
      let deviceMotionAttitudeMatrix = GLKMatrix4Make(Float(r.m11), Float(r.m21), Float(r.m31), 0,
                                                      Float(r.m12), Float(r.m22), Float(r.m32), 0,
                                                      Float(r.m13), Float(r.m23), Float(r.m33), 0,
                                                      0, 0, 0, 1)
      
      modelview = GLKMatrix4Multiply(modelview, deviceMotionAttitudeMatrix)
  
    }
    
    if let qr = quaterionRotation {
      modelview = GLKMatrix4Multiply(modelview, qr)
    }
      
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
    
    glGenRenderbuffers(1, &depthRenderBuffer)
    glBindRenderbuffer(GLenum(GL_RENDERBUFFER), depthRenderBuffer)
    glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH_COMPONENT16),GLsizei(frame.width),GLsizei(frame.height))
    
    glGenRenderbuffers(1, &colorRenderBuffer)
    glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderBuffer)
    
    context.renderbufferStorage(Int(GL_RENDERBUFFER), from: eaglLayer)
    
    var frameBuffer = GLuint()
    
    glGenFramebuffers(1, &frameBuffer)
    glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
    glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), colorRenderBuffer)
    glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_DEPTH_ATTACHMENT), GLenum(GL_RENDERBUFFER), depthRenderBuffer)
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
