//
//  Buffers.swift
//  opengl
//
//  Created by Janusz on 15/02/2017.
//  Copyright © 2017 gfm. All rights reserved.
//
import UIKit
import OpenGLES

struct Vertex {
  var position:(Float,Float,Float)
  var color:(Float,Float,Float,Float)
}

struct Buffers {
  
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
  
  lazy var colorRenderBuffer:GLuint = { return GLuint() }()
  lazy var depthRenderBuffer:GLuint = { return GLuint() }()
  
  var context:EAGLContext!
  var frame:CGSize!
  var layer:CAEAGLLayer!
  
  init(_ size:CGSize, _ glCtx:EAGLContext, _ glLayer:CAEAGLLayer) {
    
    frame = size
    context = glCtx
    layer = glLayer
    
    setupBuffers()
    setupVertexBufferObjects()
  }
  
  mutating fileprivate func setupBuffers() {
    glGenRenderbuffers(1, &depthRenderBuffer)
    glBindRenderbuffer(GLenum(GL_RENDERBUFFER), depthRenderBuffer)
    glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH_COMPONENT16),GLsizei(frame.width),GLsizei(frame.height))
    
    glGenRenderbuffers(1, &colorRenderBuffer)
    glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderBuffer)
    
    context.renderbufferStorage(Int(GL_RENDERBUFFER), from: layer)
    
    var frameBuffer = GLuint()
    
    glGenFramebuffers(1, &frameBuffer)
    glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
    glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), colorRenderBuffer)
    glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_DEPTH_ATTACHMENT), GLenum(GL_RENDERBUFFER), depthRenderBuffer)
  }
  
   func setupVertexBufferObjects() {
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
