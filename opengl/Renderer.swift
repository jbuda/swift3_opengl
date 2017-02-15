//
//  Renderer.swift
//  opengl
//
//  Created by Janusz on 15/02/2017.
//  Copyright © 2017 gfm. All rights reserved.
//

import Foundation
import OpenGLES
import GLKit

extension GLKMatrix4 {
  var array: [Float] {
    return (0..<16).map { i in
      self[i]
    }
  }
}

struct Renderer {
  
  var colorSlot:GLuint!
  var context:EAGLContext!
  var frame:CGSize!
  var indices:[GLubyte]!
  var layer:CAEAGLLayer!
  var modelViewUniform:GLuint!
  var positionSlot:GLuint!
  var projectionUniform:GLuint!
  
  init(_ size:CGSize, _ glCtx:EAGLContext, _ glLayer:CAEAGLLayer, _ mvu:GLuint, _ pu:GLuint, _ cs:GLuint, _ ps:GLuint,_ i:[GLubyte]) {
    
    frame = size
    context = glCtx
    layer = glLayer
    
    colorSlot = cs
    positionSlot = ps
    modelViewUniform = mvu
    projectionUniform = pu
    
    indices = i
    
    render()
  }
  
}

extension Renderer {
  
  fileprivate func render() {
    glClearColor(0, 104/255.0, 55.0/255.0, 1.0)
    glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
    glEnable(GLenum(GL_DEPTH_TEST))
    
    let projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), 0.5, 0.1, 10)
    
    glUniformMatrix4fv(GLint(projectionUniform), 1, 0,projection.array)
    
    var modelview = GLKMatrix4MakeTranslation(0, 0, -7)
    
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
    
    glUniformMatrix4fv(GLint(modelViewUniform), 1, 0, modelview.array)
    
    glViewport(0, 0, GLsizei(frame.width), GLsizei(frame.height))
    
    let size = GLsizei(MemoryLayout<Vertex>.size)
    glVertexAttribPointer(positionSlot, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), size,UnsafePointer<Int>(bitPattern:0))
    glVertexAttribPointer(colorSlot, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), size, UnsafePointer<Int>(bitPattern:MemoryLayout<Float>.size * 3))
    
    let vertexBufferOffset = UnsafeMutableRawPointer(bitPattern: 0)
    glDrawElements(GLenum(GL_TRIANGLES), GLsizei((indices.count * MemoryLayout<GLubyte>.size)/MemoryLayout<GLubyte>.size),GLenum(GL_UNSIGNED_BYTE), vertexBufferOffset)
    
    context.presentRenderbuffer(Int(GL_RENDERBUFFER))
  }
  
}
