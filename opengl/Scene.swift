//
//  Scene.swift
//  opengl
//
//  Created by Janusz on 15/02/2017.
//  Copyright © 2017 gfm. All rights reserved.
//

import Foundation
import OpenGLES
import GLKit
import CoreMotion

typealias DeviceRotation = (origin:CMAttitude,current:CMAttitude)

struct Scene {
  
  var buffer:BufferParams!
  var program:ColorProgram?
  
  var cube1 = Objects.Cube()
  var cube2 = Objects.Cube()
  
  struct DeviceMotion {
    static var zeroPoint:CMAttitude?
    static var quaterionRotation:GLKMatrix4!
    static var rotation:CMRotationMatrix?
  }
  
  init(_ params:BufferParams) {
    
    buffer = params
    
    Buffers.setupBuffers(params)
    
    shapes()
    construct()
  }
  
  fileprivate mutating func shapes() {
    
    cube1.create()
    cube2.create()
  }
  
  fileprivate mutating func construct() {
    let shader = Shader(for: "vertex", for: "color")
    
    if let p = shader.build() {
      program = p
      glViewport(0, 0, GLsizei(buffer.size.width), GLsizei(buffer.size.height))
    }
  }
  
  func render(_ rotation:DeviceRotation?) {
    glClearColor(0, 104/255.0, 55.0/255.0, 1.0)
    glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
    glEnable(GLenum(GL_DEPTH_TEST))
    
    if let program = program {
      
      if let r = rotation {
        deviceRotation(deviceRotation: r)
      }
      
      let projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45), 0.5, 0.1, 100)
      var modelview = GLKMatrix4MakeTranslation(0, 0, -20)
      var modelview2 = GLKMatrix4MakeTranslation(2, -5, -20)
      
      if let qr = DeviceMotion.quaterionRotation {
        modelview = GLKMatrix4Multiply(modelview, qr)
        modelview2 = GLKMatrix4Multiply(modelview2, qr)
      }
      
      cube1.draw(program,projection: projection,modelview:modelview)
      cube2.draw(program,projection: projection,modelview:modelview2)
      
      buffer.ctx.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
  }
}

extension Scene {
  
  
  fileprivate func deviceRotation(deviceRotation:DeviceRotation) {
   
    DeviceMotion.zeroPoint = DeviceMotion.zeroPoint ?? deviceRotation.origin
    deviceRotation.current.multiply(byInverseOf: DeviceMotion.zeroPoint!)
    
    let quat = deviceRotation.current.quaternion
    var quatX = quat.x
    var quatY = quat.y
    
    if quatX >= 0.1 {
      quatX = 0.1
    } else if quatX <= -0.1 {
      quatX = -0.1
    }
    
    if quatY >= 0.1 {
      quatY = 0.1
    } else if quatY <= -0.1 {
      quatY = -0.1
    }
    
    let q = GLKQuaternionMake(Float(quatX), Float(quatY), 0.0, Float(quat.w))
    
    DeviceMotion.quaterionRotation = GLKMatrix4MakeWithQuaternion(q)
  }
}
