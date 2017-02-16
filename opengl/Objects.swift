//
//  Objects.swift
//  opengl
//
//  Created by Janusz on 15/02/2017.
//  Copyright © 2017 gfm. All rights reserved.
//

import Foundation
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

protocol Drawable {
  var vertices:[Vertex] { get set }
  var indices:[GLubyte] { get set }
  
  mutating func create()
}

struct Objects {
  
  struct Cube:Drawable {
    
    fileprivate var bufferObjects:BufferObjects!
    
    var vertices = [
      Vertex(position:(1,-1,1),color:(1,0,0,1)),
      Vertex(position:(1,1,1),color:(0,1,0,1)),
      Vertex(position:(-1,1,1),color:(0,0,1,1)),
      Vertex(position:(-1,-1,1),color:(0,0,0,1)),
      Vertex(position:(1,-1,-1),color:(1,0,0,1)),
      Vertex(position:(1,1,-1),color:(1,0,0,1)),
      Vertex(position:(-1,1,-1),color:(0,1,0,1)),
      Vertex(position:(-1,-1,-1),color:(0,1,0,1))
    ]
    
    var indices:[GLubyte] = [
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
    
    
    mutating func create() {
      bufferObjects = Buffers.createVBO(vertices, indices)
    }
    
    func draw(_ p:ColorProgram,projection proj:GLKMatrix4,modelview m:GLKMatrix4) {
      
      glUseProgram(p.program)
      
      glUniformMatrix4fv(GLint(p.projection), 1, 0,proj.array)
      glUniformMatrix4fv(GLint(p.modelview), 1, 0, m.array)
      
      glBindBuffer(GLenum(GL_ARRAY_BUFFER), bufferObjects.vertex)
      
      let size = GLsizei(MemoryLayout<Vertex>.size)
      glVertexAttribPointer(p.position, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), size,UnsafePointer<Int>(bitPattern:0))
      glVertexAttribPointer(p.color, 4, GLenum(GL_FLOAT), GLboolean(GL_FALSE), size, UnsafePointer<Int>(bitPattern:MemoryLayout<Float>.size * 3))
      glEnableVertexAttribArray(p.position)
      glEnableVertexAttribArray(p.color)
      
      glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), bufferObjects.index)
      
      let vertexBufferOffset = UnsafeMutableRawPointer(bitPattern: 0)
      glDrawElements(GLenum(GL_TRIANGLES), GLsizei((indices.count * MemoryLayout<GLubyte>.size)/MemoryLayout<GLubyte>.size),GLenum(GL_UNSIGNED_BYTE), vertexBufferOffset)
      
    }
  }
}
