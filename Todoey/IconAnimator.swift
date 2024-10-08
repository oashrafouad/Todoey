import Foundation
import QuartzCore

class IconAnimator {

    /// How many frames the animation has
    private let numberOfFrames: Int

    /// The number of times to loop the animation
    private let numberOfLoops: Int

    /// What FPS to animate at
    private let targetFramesPerSecond: CGFloat

    /// Whether or not the animation should run by blocking the main queue.
    /// This may give better performance (at the expense of not being able to do
    /// much else while the animation is happening)
    private let shouldRunOnMainThread: Bool

    /// The `MyCustomProxy` used to set the application icon
    private let appProxy: NSObject = MyCustomProxy.customProxyForCurrentProcess() as! NSObject

    /// The time at which our animated started
    private var animationStartTime: CFTimeInterval = 0

    /// The number of times the animation has looped already
    private var currentLoopCount = 0

    /// Stores the completion block passed to `startAnimation`
    private var completion: (() -> Void)? = nil

    /// Whether or not this animation has been cancelled
    private var isCancelled = false

    init(numberOfFrames: Int,
         numberOfLoops: Int = 1,
         targetFramesPerSecond: CGFloat = 30,
         shouldRunOnMainThread: Bool = false) {
        self.numberOfFrames = numberOfFrames
        self.targetFramesPerSecond = targetFramesPerSecond
        self.shouldRunOnMainThread = shouldRunOnMainThread
        self.numberOfLoops = numberOfLoops
    }

    /// Starts a new app icon animation. Can be called multiple times.
    func startAnimation(completion: (() -> Void)? = nil) {
        // Set/reset properties
        animationStartTime = CACurrentMediaTime()
        currentLoopCount = 0
        isCancelled = false
        self.completion = completion

        // Start the animation, either using the main thread loop
        // or timer, depending on configuration
        if shouldRunOnMainThread {
            startAnimationOnMainThread()
        } else {
            startAnimationUsingTimer()
        }
    }

    /// Cancel the current animation, if any
    func cancel() {
        isCancelled = true
        completion?()
    }

    /// Runs the icon animation using a `CFRunLoopTimer`
    private func startAnimationUsingTimer() {
        // Calculate the duration of each frame, in seconds
        let frameDuration = 1.0 / targetFramesPerSecond

        // Calculate the time when we should start our timer.
        // This is set to be halfway through the next frame interval,
        // so that when we try to determine what frame we're on,
        // we're well in the middle of a frame range
        let startTime = animationStartTime + (frameDuration / 2)

        // Create a timer to run every frame
        let timer = CFRunLoopTimerCreateWithHandler(
            /* allocator: */ kCFAllocatorDefault,
            /* fireDate: */ startTime,
            /* interval: */ frameDuration,
            /* flags: */ 0,
            /* order */ 0
        ) { [weak self] timer in
            guard let self else {
                return
            }

            // If our animation was cancelled,
            // invalidate our timer and do nothing
            if isCancelled {
                CFRunLoopTimerInvalidate(timer)
            }

            // On every frame, update our icon
            let shouldContinue = self.updateFrame()

            // If we've reached our last frame,
            // invalidate the timer and call our completion block
            if (!shouldContinue) {
                CFRunLoopTimerInvalidate(timer)
                self.completion?()
            }
        }

        // Start the timer
        CFRunLoopAddTimer(CFRunLoopGetMain(), timer, CFRunLoopMode.commonModes)
    }

    /// Runs the icon animation using a loop on the main thread
    /// (sometimes better performance than `startAnimationUsingTimer`,
    /// at the expense of not being able to do other work while animating)
    private func startAnimationOnMainThread() {
        // Calculate the duration of each frame, in seconds
        let frameDuration = 1.0 / targetFramesPerSecond

        // Store the time at which we last updated the frame
        // (starting with 0, meaning we're ready to show the
        // first frame immediately)
        var lastFrameTime: CFTimeInterval = 0

        DispatchQueue.main.async {
            while (true) {
                // If our animation has been cancelled,
                // break out of our loop immediately
                if self.isCancelled {
                    break
                }

                // Check if it's been at least one frame
                // since the last time we updated our icon
                // (otherwise, just sleep)
                let currentTime = CACurrentMediaTime()
                if currentTime - lastFrameTime < frameDuration {
                    Thread.sleep(forTimeInterval: 0.001)
                    continue
                }

                // Mark the current time so that we can
                // figure out when we need to show the next frame
                lastFrameTime = currentTime

                // If we've reached our last frame,
                // call our completion block and break
                // out of our loop
                let shouldContinue = self.updateFrame()
                if (!shouldContinue) {
                    self.completion?()
                    break
                }
            }
        }
    }

    private func updateFrame() -> Bool {
        // Determine the frame we _should_ be showing
        // based on the current time. This allows the animation
        // to continue smoothly even if some frames are dropped
        let timeSinceStart = CACurrentMediaTime() - animationStartTime
        let currentFrame = Int(timeSinceStart * targetFramesPerSecond) % numberOfFrames

        // Define the range of icons
        let iconRange = 2...6
        let iconCount = iconRange.count
        let iconIndex = iconRange.lowerBound + (currentFrame % iconCount)
        let iconName = String(format: "AppIcon%d", iconIndex)
        print(iconName)

        // Use dynamic invocation to call the private API method
        let selector = NSSelectorFromString("setAlternateIconName:completionHandler:")
        if appProxy.responds(to: selector) {
            let method = appProxy.method(for: selector)
            typealias Function = @convention(c) (AnyObject, Selector, String?, ((Bool, Error?) -> Void)?) -> Void
            let function = unsafeBitCast(method, to: Function.self)
            function(appProxy, selector, iconName) { success, error in
                if let error = error {
                    print("Error: \(error)")
                }
            }
        }

        // If we've reached the end of a loop...
        if currentFrame == 0 {
            // Check if we've looped as many times as we'd like.
            // If so, return `false` to indicate that we're done animating
            if currentLoopCount == numberOfLoops {
                return false
            }
            currentLoopCount += 1
        }

        return true
    }
}
