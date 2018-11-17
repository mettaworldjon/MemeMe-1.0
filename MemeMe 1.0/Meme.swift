//
//  Meme.swift
//  MemeMe 1.0
//
//  Created by Jonathan on 11/16/18.
//  Copyright © 2018 Jonathan. All rights reserved.
//

import UIKit

struct Meme {
    var topTextField:String?
    var bottomTextField:String?
    var originalImage:UIImage?
    var memedImage:UIImage?
    
    
    init(topTextField: String, bottomTextField: String, originalImage: UIImage, memedImage: UIImage) {
        self.topTextField = topTextField
        self.bottomTextField = bottomTextField
        self.originalImage = originalImage
        self.memedImage = memedImage
    }
}
