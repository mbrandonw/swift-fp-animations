import QuartzCore
import UIKit

public final class Drive: NSObject {
  /// `maxSteps` is for use in a playground only. It kills the display link after that many steps so that
  /// playgrounds don't crash.
  private var maxSteps: Int
  private var displayLink: CADisplayLink!
  private var animations: [(startTime: CFAbsoluteTime, Animation<Void>)] = []

  public init(maxSteps: Int = Int.max) {
    self.maxSteps = maxSteps
    super.init()
    self.displayLink = UIScreen.main.displayLink(withTarget: self, selector: #selector(step(_:)))
    //CADisplayLink(target: self, selector: #selector(step(_:)))
    self.displayLink.add(to: RunLoop.main, forMode: .commonModes)
  }

  public func append(animation: Animation<Void>) {
    guard animation.duration > 0 else { return }

    DispatchQueue.main.async {
      self.animations.append((self.displayLink.targetTimestamp, animation))
    }
  }

  private var currentSteps = 0
  @objc private func step(_ displayLink: CADisplayLink) {
    self.currentSteps += 1
    if self.currentSteps > self.maxSteps {
      self.displayLink.invalidate()
    }

    let time = displayLink.targetTimestamp
    var indicesToRemove: [Int] = []

    for (idx, startTimeAndAnimation) in self.animations.enumerated() {
      let (startTime, animation) = startTimeAndAnimation
      let t = (time - startTime) / animation.duration
      if t <= 1 {
        animation.value(t)
      } else {
        animation.value(1)
        indicesToRemove.append(idx)
      }
    }

    indicesToRemove.reversed().forEach { self.animations.remove(at: $0) }
  }
}
