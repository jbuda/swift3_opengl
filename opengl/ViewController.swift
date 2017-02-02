//
//  ViewController.swift
//  opengl
//
//  Created by Janusz on 01/02/2017.
//  Copyright © 2017 gfm. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let glView = OpenGL(frame: view.frame)
    
    view.addSubview(glView)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

