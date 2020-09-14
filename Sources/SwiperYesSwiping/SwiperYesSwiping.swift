//
//  SwiperYesSwiping.swift
//
//
//  Created by MMQ on 9/11/20.
//

import UIKit

public class SwiperYesSwiping {
    
    // MARK: - Customization
    
    /// The view you want to add the buttons to.
    public var view: UIView?
    
    /// The left image icon.
    public var leftImage: UIImage?
    
    /// The right image icon.
    public var rightImage: UIImage?
    
    /// The icon shown when the user swipes either icon to the top.
    /// If this is not set, there will be no top action nor ability to vertically move the icons.
    public var topImage: UIImage?
    
    /// Set this to your desired color if you want both icons (right and left) to use the same tint color.
    /// If you want to use different colors for each, set `leftImageTintColor` and `rightImageTintColor`
    public var bothImageTintColor: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor { $0.userInterfaceStyle == .dark ? .white : .black }
        } else {
            return .black
        }
    }()
    
    /// Sets the left image tint to desired color.
    /// If you wish to use the same color for the right and left images, set `bothImageTintColor` instead.
    public var leftImageTintColor: UIColor?
    
    /// Sets the right image tint to desired color.
    /// If you wish to use the same color for the right and left images, set `bothImageTintColor` instead.
    public var rightImageTintColor: UIColor?
    
    /// Sets the icon image width. Default is 34.
    public var imageWidth: CGFloat = 34 {
        didSet {
            dragHiddenConstant = self.imageWidth
        }
    }
    
    /// Set this to the edge insets you want for the image when it popped out. The larger the number, the further from the edges.
    public var sideMarginsWhenFullySwiped: CGFloat = 15
    
    /// Disable to not use haptic feedback.
    public var usesHaptics = true
    
    
    // MARK: - Actions
    
    /// Function called when the user fully completes a swipe.
    ///
    /// - parameter sideSwiped: The swiped side.
    public var didCompleteSwipe: ((sideSwiped) -> Void)?
    
    /// Function called when the swipes but then cancels the swipe.
    ///
    /// - parameter sideSwiped: The swiped side before being cancelled.
    public var didCancelSwipe: ((sideSwiped) -> Void)?
    
    
    // MARK: - Functions
    
    public init() {}
    
    /// Activates the swipers.
    public func activate() {
        guard self.panGesture == nil else { print("Attempting to add swiper even though it has already been added."); return }
        panGesture = HPGestureRecognizer(target: self, action: #selector(swiperSwiped(sender:)))
        view?.addGestureRecognizer(panGesture!)
    }
    
    /// Deactivates the swipers.
    public func deactivate() {
        guard let existingPanGesture = self.panGesture else { print("Attempting to deactivate swiper even though it has not been activated"); return }
        view?.removeGestureRecognizer(existingPanGesture)
    }
    
    
    // MARK: - Additional
    
    public enum sideSwiped {
        case left, right, top
    }
    
    
    
    
    // MARK: - Private
    
    private var panGesture: HPGestureRecognizer?
    private lazy var dragIconImageView = UIImageView()
    private lazy var dragIconLeadingTrailingConstraint = NSLayoutConstraint()
    private lazy var dragIconCenterConstraint = NSLayoutConstraint()
    private var dragIsReset = false
    private var dragHiddenConstant: CGFloat = 34
    
    @objc private func swiperSwiped(sender: HPGestureRecognizer) {
        guard let view = self.view else { return }
        
        let velocity = sender.velocity(in: view)
        let translation = sender.translation(in: view)
        
        let languageDirection = UIApplication.shared.userInterfaceLayoutDirection
        let selectedTopImage = self.topImage != nil
        
        switch sender.state {
        case .began:
            dragIconImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            dragIconImageView.alpha = 0.4
            dragIconImageView.tintColor = self.bothImageTintColor
            
            dragIconImageView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(dragIconImageView)
            dragIconCenterConstraint = dragIconImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            NSLayoutConstraint.activate([
                dragIconImageView.widthAnchor.constraint(equalToConstant: abs(dragHiddenConstant)),
                dragIconImageView.heightAnchor.constraint(equalToConstant: abs(dragHiddenConstant)),
                dragIconCenterConstraint
            ])
            
            if velocity.x > 0 {
                // Left side
                if let leftTint = self.leftImageTintColor {
                    dragIconImageView.tintColor = leftTint
                }
                dragHiddenConstant = -imageWidth
                dragIconLeadingTrailingConstraint = dragIconImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: dragHiddenConstant)
                dragIconImageView.image = leftImage
            } else {
                // Right side
                if let rightTint = self.rightImageTintColor {
                    dragIconImageView.tintColor = rightTint
                }
                dragHiddenConstant = imageWidth
                dragIconLeadingTrailingConstraint = dragIconImageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: dragHiddenConstant)
                dragIconImageView.image = rightImage
            }
            dragIconLeadingTrailingConstraint.isActive = true
            view.layoutSubviews()
            
        case .changed:
            let updateY = (translation.y < 0 && translation.y > -80) && selectedTopImage
            
            if updateY {
                if translation.y < -30 {
                    if !dragIsReset {
                        if usesHaptics { Haptics.default() }
                        dragIconImageView.image = topImage
                    }
                    dragIsReset = true
                } else if dragIsReset {
                    dragIconImageView.image = dragHiddenConstant > 0 ? rightImage : leftImage
                    dragIsReset = false
                }
            }
            
            UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .curveEaseInOut]) { [self] in
                if updateY { self.dragIconCenterConstraint.constant = translation.y }
                self.dragIconLeadingTrailingConstraint.constant = self.dragHiddenConstant < 0 ? min(translation.x + self.dragHiddenConstant, self.sideMarginsWhenFullySwiped) : max(translation.x + self.dragHiddenConstant, -sideMarginsWhenFullySwiped)
                view.layoutSubviews()
            }
            
            if dragIconImageView.alpha != 1 && abs(translation.x) >= 50 {
                if usesHaptics { Haptics.light() }
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
                // Completed
                if dragIsReset {
                    didCompleteSwipe?(.top)
                    dragIsReset = false
                } else {
                    if velocity.x > 0 {
                        didCompleteSwipe?(languageDirection == .leftToRight ? .left : .right)
                    } else {
                        didCompleteSwipe?(languageDirection == .leftToRight ? .right : .left)
                    }
                }
            } else {
                // Cancelled
                if dragIsReset {
                    didCancelSwipe?(.top)
                    dragIsReset = false
                } else {
                    if velocity.x > 0 {
                        didCancelSwipe?(languageDirection == .leftToRight ? .left : .right)
                    } else {
                        didCancelSwipe?(languageDirection == .leftToRight ? .right : .left)
                    }
                }
            }
            
            UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .curveEaseInOut]) {
                self.dragIconImageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                self.dragIconImageView.alpha = 0
                self.dragIconLeadingTrailingConstraint.constant = self.dragHiddenConstant
                self.dragIconCenterConstraint.constant = 0
                view.layoutSubviews()
            } completion: { _ in
                NSLayoutConstraint.deactivate([self.dragIconLeadingTrailingConstraint, self.dragIconCenterConstraint])
                self.dragIconImageView.removeFromSuperview()
            }
        default: break
        }
    }
    
}
