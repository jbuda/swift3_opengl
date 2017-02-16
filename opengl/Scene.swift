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
    
  }
  
  fileprivate mutating func construct() {
    glClearColor(0, 104/255.0, 55.0/255.0, 1.0)
    glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
    glEnable(GLenum(GL_DEPTH_TEST))
    
    let shader = Shader(for: "vertex", for: "color")
    
    if let p = shader.build() {
      program = p
      glViewport(0, 0, GLsizei(buffer.size.width), GLsizei(buffer.size.height))
    }
      
      //
    

      
      /*
 
       
       //var modelview = GLKMatrix4MakeTranslation(0, 0, -7)
       
       
       
       //    if let r = rotation {
       //
       //      let deviceMotionAttitudeMatrix = GLKMatrix4Make(Float(r.m11), Float(r.m21), Float(r.m31), 0,
       //                                                      Float(r.m12), Float(r.m22), Float(r.m32), 0,
       //                                                      Float(r.m13), Float(r.m23), Float(r.m33), 0,
       //                                                      0, 0, 0, 1)
       //
       //      modelview = GLKMatrix4Multiply(modelview, deviceMotionAttitudeMatrix)
       //
       //    }
       //
       //    if let qr = quaterionRotation {
       //      modelview = GLKMatrix4Multiply(modelview, qr)
       //    }
       
       //    glUniformMatrix4fv(GLint(modelViewUniform), 1, 0, modelview.array)
 */
      

  }
  
  func render(_ rotation:DeviceRotation?) {
    if let program = program {
      
      if let r = rotation {
        deviceRotation(rotation)
      }
      
      let projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), 0.5, 0.1, 10)
      let modelview = GLKMatrix4MakeTranslation(0, 0, -7)
      
      cube1.draw(program,projection: projection,modelview:modelview)
    
      buffer.ctx.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
  }
}

extension Scene {
  
  
  fileprivate func deviceRotation(rotation:DeviceRotation) {
   
    DeviceMotion.zeroPoint = DeviceMotion.zeroPoint ?? reset
    attitude.multiply(byInverseOf: DeviceMotion.zeroPoint!)
    
    let quat = attitude.quaternion
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
    
    DeviceMotion.quaterionRotation = GLKMatrix4MakeWithQuaternion(q)
  }
}
