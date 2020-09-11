//
//  HPGestureRecognizer.swift
//  SwiperYesSwiping
//
//  Created by MMQ on 9/11/20.
//

import UIKit

class HPGestureRecognizer: UIPanGestureRecognizer {
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        if state == .began {
            let vel = velocity(in: view)
            if abs(vel.y) > abs(vel.x) {
                state = .cancelled
            }
        }
    }
}
