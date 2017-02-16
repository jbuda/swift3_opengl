//
//  Shader.swift
//  opengl
//
//  Created by Janusz on 16/02/2017.
//  Copyright © 2017 gfm. All rights reserved.
//

import Foundation
import OpenGLES

typealias ColorProgram = (program:GLuint,position:GLuint,color:GLuint,projection:GLuint,modelview:GLuint)

struct Shader {
  
  var vertex:String!
  var fragment:String!
  
  init(for vsh:String,for fsh:String) {
    vertex = vsh
    fragment = fsh
  }
  
  func build()->ColorProgram? {
    let vertex = load(self.vertex,type:GLenum(GL_VERTEX_SHADER))
    let fragment = load(self.fragment, type:GLenum(GL_FRAGMENT_SHADER))
    
    if let v = vertex, let f = fragment {
      
      let p = link(v, f)
      
      let position = GLuint(glGetAttribLocation(p, "Position"))
      let color = GLuint(glGetAttribLocation(p, "SourceColor"))
      let projection = GLuint(glGetUniformLocation(p, "Projection"))
      let modelview = GLuint(glGetUniformLocation(p, "Modelview"))
      
      
      return ColorProgram(program:p,position:position,color:color,projection:projection,modelview:modelview)
    } else {
      assert(false, "Shaders not loaded")
    }
    
    return nil
  }
  
  fileprivate func load(_ shader:String,type with:GLenum)->GLuint? {
    
    guard let filepath = getFilePath(shader),let compiled = compile(file:filepath,with:with) else {
      assert(false, "Cannot compile shader :\(shader)")
      return nil
    }
    
    return compiled
  }
  
  fileprivate func compile(file path:String,with type:GLenum)->GLuint? {

    do {
      
      let contents = try String(contentsOfFile: path, encoding: .utf8)
      var contentsUTF8 = UnsafePointer<GLchar>(contents.cString(using:.utf8))
      let shaderObj = glCreateShader(type)
      var contentsLength = GLint(contents.characters.count)
      var compileStatus = GLint()
      
      assert(shaderObj != 0)
      
      glShaderSource(shaderObj, 1, &contentsUTF8, &contentsLength)
      glCompileShader(shaderObj)
      glGetShaderiv(shaderObj, GLenum(GL_COMPILE_STATUS), &compileStatus)
      
      return shaderObj
    } catch {
      print("Error! \(error.localizedDescription)")
    }
 
    return nil
  }
  
  fileprivate func getFilePath(_ name:String)->String? {
    return Bundle.main.path(forResource: name, ofType: ".glsl", inDirectory:"shaders/",forLocalization:nil)
  }
  
  fileprivate func link(_ vertexShader:GLuint,_ fragmentShader:GLuint)->GLuint {
    
    let program = glCreateProgram()
    var linkStatus = GLint()
    
    glAttachShader(program, vertexShader)
    glAttachShader(program, fragmentShader)
    glLinkProgram(program)
    glGetProgramiv(program, GLenum(GL_LINK_STATUS), &linkStatus)
    
    return program
  }
  
}
