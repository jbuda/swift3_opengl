//
//  Shaders.swift
//  opengl
//
//  Created by Janusz on 15/02/2017.
//  Copyright © 2017 gfm. All rights reserved.
//

import Foundation
import OpenGLES

struct Shaders {
  
  var colorSlot:GLuint!
  var modelViewUniform:GLuint!
  var positionSlot:GLuint!
  var projectionUniform:GLuint!
  
  init() {
    compileShaders()
  }
  
}

extension Shaders {

  mutating fileprivate func compileShaders() {
    
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
