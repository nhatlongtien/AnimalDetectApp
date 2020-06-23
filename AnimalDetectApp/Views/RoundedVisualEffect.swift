//
//  RoundedVisualEffect.swift
//  AnimalDetectApp
//
//  Created by NGUYENLONGTIEN on 6/22/20.
//  Copyright © 2020 NGUYENLONGTIEN. All rights reserved.
//

import UIKit

class RoundedVisualEffect: UIVisualEffectView {

    override func awakeFromNib() {
        self.layer.cornerRadius = 10
        self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMinYCorner]
        self.clipsToBounds = true
    }

}
