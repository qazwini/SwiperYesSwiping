//
//  SwiperYesSwiping.swift
//
//
//  Created by MMQ on 9/11/20.
//

import UIKit

public class SwiperYesSwiping: NSObject {
    
    // MARK: Customization
    
    public var leftImage: UIImage?
    public var rightImage: UIImage?
    public var bothImageTintColor: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor { $0.userInterfaceStyle == .dark ? .white : .black }
        } else {
            return .black
        }
    }()
    public var leftImageTintColor: UIColor?
    public var rightImageTintColor: UIColor?
    public var imageWidth: CGFloat = 34 {
        didSet {
            dragHiddenConstant = self.imageWidth
        }
    }
    public var sideMarginsWhenFullySwiped: CGFloat = 15
    
    // MARK: Actions
    
    public var didCompleteSwipe: ((sideSwiped) -> Void)?
    public var didCancelSwipe: ((sideSwiped) -> Void)?
    
    // MARK: Functions
    
    public func addSwiper() {
        guard self.panGesture == nil else { print("Attempting to add swiper even though it has already been added."); return }
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(swiperSwiped(sender:)))
        mainWindow?.addGestureRecognizer(panGesture!)
    }
    
    public func deactivate() {
        guard let existingPanGesture = self.panGesture else { print("Attempting to deactivate swiper even though it has not been activated"); return }
        mainWindow?.removeGestureRecognizer(existingPanGesture)
    }
    
    // MARK: Additional
    
    public enum sideSwiped {
        case left, right
    }
    
    
    // MARK: - Private
    
    private lazy var mainWindow: UIWindow? = UIApplication.shared.windows.first { $0.isKeyWindow }
    
    private var panGesture: UIPanGestureRecognizer?
    private lazy var dragIconImageView = UIImageView()
    private lazy var dragIconLeadingTrailingConstraint = NSLayoutConstraint()
    private lazy var dragIconCenterConstraint = NSLayoutConstraint()
    private var dragIsReset = false
    private var dragHiddenConstant: CGFloat = 34
    
    @objc func swiperSwiped(sender: UIPanGestureRecognizer) {
        guard let mainWindow = self.mainWindow else { return }
        
        let velocity = sender.velocity(in: mainWindow)
        let translation = sender.translation(in: mainWindow)
        
        switch sender.state {
        case .began:
            dragIconImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            dragIconImageView.alpha = 0.4
            dragIconImageView.tintColor = imageTintColor
            dragIconImageView.layer.shadowOpacity = isDarkMode() ? 0 : 0.1
            dragIconImageView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(dragIconImageView)
            dragIconCenterConstraint = dragIconImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            NSLayoutConstraint.activate([dragIconImageView.widthAnchor.constraint(equalToConstant: abs(dragHiddenConstant)), dragIconImageView.heightAnchor.constraint(equalToConstant: abs(dragHiddenConstant)), dragIconCenterConstraint])
            if velocity.x > 0 {
                // Decrease day (if LTR)
                dragHiddenConstant = -34
                dragIconLeadingTrailingConstraint = dragIconImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: dragHiddenConstant)
                dragIconImageView.image = UIImage(named: "leftHome")?.withRenderingMode(.alwaysTemplate)
            } else {
                // Increase day (if LTR)
                dragHiddenConstant = 34
                dragIconLeadingTrailingConstraint = dragIconImageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: dragHiddenConstant)
                dragIconImageView.image = UIImage(named: "rightHome")?.withRenderingMode(.alwaysTemplate)
            }
            dragIconLeadingTrailingConstraint.isActive = true
            view.layoutSubviews()
        case .changed:
            let updateY = translation.y < 0 && translation.y > -80  // < 20
            
            if updateY {
                if translation.y < -30 {
                    if !dragIsReset {
                        hapticFeedback()
                        dragIconImageView.image = UIImage(named: "calendarHome")?.withRenderingMode(.alwaysTemplate)
                    }
                    dragIsReset = true
                } else if dragIsReset {
                    dragIconImageView.image = UIImage(named: dragHiddenConstant > 0 ? "rightHome" : "leftHome")?.withRenderingMode(.alwaysTemplate)
                    dragIsReset = false
                }
            }
            
            UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .curveEaseInOut]) {
                if updateY { self.dragIconCenterConstraint.constant = translation.y }
                self.dragIconLeadingTrailingConstraint.constant = self.dragHiddenConstant < 0 ? min(translation.x + self.dragHiddenConstant, 20) : max(translation.x + self.dragHiddenConstant, -20)
                mainWindow.layoutSubviews()
            }
            
            if dragIconImageView.alpha != 1 && abs(translation.x) >= 50 {
                hapticFeedback(style: .light)
                UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .curveEaseInOut]) {
                    self.dragIconImageView.transform = .identity
                    self.dragIconImageView.alpha = 1
                }
            } else if abs(translation.x) < 50 {
                UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .curveEaseInOut]) {
                    self.dragIconImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    self.dragIconImageView.alpha = 0.4
                }
            }
        case .ended:
            if dragIconImageView.alpha == 1 {
                if dragIsReset {
                    panAdjustment = 0
                    dragIsReset = false
                } else {
                    if velocity.x > 0 {
                        isRightSide() ? (panAdjustment += 1) : (panAdjustment -= 1)
                    } else {
                        isRightSide() ? (panAdjustment -= 1) : (panAdjustment += 1)
                    }
                }
                
                DispatchQueue.main.async {
                    self.setNafilahs(withAdjustment: self.panAdjustment)
                    UIView.transition(with: self.collectionView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        self.collectionView.reloadData()
                    })
                }
            }
            
            UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .curveEaseInOut]) {
                self.dragIconImageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                self.dragIconImageView.alpha = 0
                self.dragIconLeadingTrailingConstraint.constant = self.dragHiddenConstant
                self.dragIconCenterConstraint.constant = 0
                mainWindow.layoutSubviews()
            } completion: { _ in
                NSLayoutConstraint.deactivate([self.dragIconLeadingTrailingConstraint, self.dragIconCenterConstraint])
                self.dragIconImageView.removeFromSuperview()
            }
        default: break
        }
    }
    
}
