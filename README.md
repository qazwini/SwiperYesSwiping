# SwiperYesSwiping

Add a floating left/right page action in Swift.

## Demo

![Demo GIF](https://user-images.githubusercontent.com/42902912/92921212-a5add900-f401-11ea-942c-8fcaddfae523.gif)


## Requirements

- iOS 10.0+


## Integration

### Manually

This repo only uses three files, so you can either
1. Download this repo and drag and drop the `SwiperYesSwiping.swift`, `HPGestureRecognizer.swift`, and `Haptics.swift` files into your project
2. Or copy paste their code into a swift file in your project.

### Swift Package Manager

You can also integrate it into your project using Swift Package Manager.
In Xcode, go to `File -> Swift Packages -> Add Package Dependency` and paste in the repo's url: `https://github.com/qazwini/SwiperYesSwiping`.


## Usage

If you are using Swift Package Manager, you need to add `Import SwiperYesSwiping` into the file you would like to use it in. 

- Initialize `let swiper = SwiperYesSwiping()` somewhere in your class.
- Set the `view` property to the whichever view controller's view or any other view you'd like to add this on. If you don't, it will automatically choose the top view controller at the time that `activate()` is run.
- Set the `leftImage` and `rightImage` to any image you want. You can use SF Symbols as well. If you are adding a top action, also add a `topImage`. In the demo, all the icons are SF Symbols. The left icon is `chevron.left.circle.fill`, right is `chevron.right.circle.fill`, and top is `calendar.circle.fill`.
- Set the `didCompleteSwipe()` function to whatever function you want to run when the user fully completes the action. The `sideSwiped` will be `top` if the user highered it (if you did not set an image for `topImage`, this will not run).
- Set the `didCancelSwipe()` function to whatever function you want to run when the user swipes but then cancels their swipe.
- Make sure to run the `activate()` function to set up the gesture recognizer. If you wish to remove the recognizer from the view, use `deactivate()`.

### Example Usage

```
class ViewController: UIViewController {
    let swiper = SwiperYesSwiping()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        swiper.view = view
        swiper.leftImage = UIImage(systemName: "chevron.left.circle.fill")
        swiper.rightImage = UIImage(systemName: "chevron.right.circle.fill")
        swiper.topImage = UIImage(systemName: "calendar.circle.fill")
        swiper.bothImageTintColor = .white
        swiper.didCompleteSwipe = { side in
            switch side {
            case .left: print("User swiped left")
            case .right: print("User swiped right")
            case .top: print("User raised arrow")
            }
        }
        swiper.sideMarginsWhenFullySwiped = 20
        swiper.activate()
    }
}
```

### Additional Customization

- `bothImageTintColor`. If you want to use the same color for both the right and left images, set this to whatever color you want. Remember to set `withTemplateMode(.alwaysTemplate)` when setting the left/right/top images if you want to change their tint color.
- `leftImageTintColor` and `rightImageTintColor`. If you want to use different colors for each side, set these.
- `imageWidth`. Set this to whatever size you want the icon to be. Default is 34.
- `sideMarginsWhenFullySwiped`. Set this to the edge insets you want for the image when it popped out. The larger the number, the further from the edges.
- `usesHaptics`. Set this to `false` if you do not want haptic feedback.
