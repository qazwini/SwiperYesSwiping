//
//  Haptics.swift
//  SwiperYesSwiping
//
//  Created by MMQ on 9/11/20.
//

import UIKit

class Haptics {
    class func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    class func `default`() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}
