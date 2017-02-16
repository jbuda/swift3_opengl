//
//  Buffers.swift
//  opengl
//
//  Created by Janusz on 15/02/2017.
//  Copyright © 2017 gfm. All rights reserved.
//
import UIKit
import OpenGLES

typealias BufferParams = (size:CGSize,ctx:EAGLContext,layer:CAEAGLLayer)
typealias BufferObjects = (vertex:GLuint,index:GLuint)

struct Buffers {
  
  static var colorRenderBuffer = GLuint()
  static var depthRenderBuffer = GLuint()
  
  static func setupBuffers(_ params:BufferParams) {
    glGenRenderbuffers(1, &depthRenderBuffer)
    glBindRenderbuffer(GLenum(GL_RENDERBUFFER), depthRenderBuffer)
    glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH_COMPONENT16),GLsizei(params.size.width),GLsizei(params.size.height))
    
    glGenRenderbuffers(1, &colorRenderBuffer)
    glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderBuffer)
    
    params.ctx.renderbufferStorage(Int(GL_RENDERBUFFER), from: params.layer)
    
    var frameBuffer = GLuint()
    
    glGenFramebuffers(1, &frameBuffer)
    glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
    glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), colorRenderBuffer)
    glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_DEPTH_ATTACHMENT), GLenum(GL_RENDERBUFFER), depthRenderBuffer)
  }

  static func createVBO(_ vertices:[Vertex],_ indices:[GLubyte])->BufferObjects {
    
    var vertexBuffer = GLuint()
    var indexBuffer = GLuint()

    glGenBuffers(1, &vertexBuffer)
    glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
    glBufferData(GLenum(GL_ARRAY_BUFFER), (vertices.count * MemoryLayout<Vertex>.size), vertices, GLenum(GL_STATIC_DRAW))

    glGenBuffers(1, &indexBuffer)
    glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer)
    glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), (indices.count * MemoryLayout<GLubyte>.size), indices, GLenum(GL_STATIC_DRAW))
    
    return (vertex:vertexBuffer,index:indexBuffer)
  }
  
}
