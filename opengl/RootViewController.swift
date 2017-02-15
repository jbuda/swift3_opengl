//
//  RootViewController.swift
//  opengl
//
//  Created by Janusz on 15/02/2017.
//  Copyright © 2017 gfm. All rights reserved.
//
import UIKit

class RootViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let glView = OpenGLView(frame: view.frame)
    
    view.addSubview(glView)
  }
}
