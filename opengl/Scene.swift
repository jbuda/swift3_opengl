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

struct Scene {
  
  var buffer:BufferParams!
  
  init(_ params:BufferParams) {
    
    buffer = params
    
    Buffers.setupBuffers(params)
    construct()
  }
  
  fileprivate mutating func construct() {
    glClearColor(0, 104/255.0, 55.0/255.0, 1.0)
    glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
    glEnable(GLenum(GL_DEPTH_TEST))
    
    var cube1 = Objects.Cube()
    cube1.create()
    
    let shader = Shader(for: "vertex", for: "color")
    if let g = shader.build() {
      glViewport(0, 0, GLsizei(buffer.size.width), GLsizei(buffer.size.height))
    
      let projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), 0.5, 0.1, 10)
      let modelview = GLKMatrix4MakeTranslation(0, 0, -7)
      
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
      
      cube1.draw(g,projection: projection,modelview:modelview)
      
      buffer.ctx.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
  }
}
