import CoreGraphics

public struct Animation<A> {
  public let duration: CFAbsoluteTime
  private let _value: (CFAbsoluteTime) -> A

  public init(duration: CFAbsoluteTime, value: @escaping (CFAbsoluteTime) -> A) {
    self.duration = duration
    self._value = value
  }

  public func value(_ t: CFAbsoluteTime) -> A {
    precondition(self.duration > 0, "Can't call zero-duration animations.")
    return self._value(t)
  }

  public var start: A {
    return self._value(0)
  }

  public var end: A {
    return self._value(1)
  }

  /// Converts a pure animation into an effectful animatino.
  public func `do`(_ f: @escaping (A) -> Void) -> Animation<Void> {
    return .init(duration: self.duration) { t in
      f(self.value(t))
    }
  }

  /// Binds the animation to an object with a keyPath.
  public func bind<B>(_ obj: B, with keyPath: ReferenceWritableKeyPath<B, A>) -> Animation<Void> {
    return self.do { a in
      obj[keyPath: keyPath] = a
    }
  }

  /// Transforms the outut of the animation.
  public func map<B>(_ f: @escaping (A) -> B) -> Animation<B> {
    return .init(duration: self.duration) { t in f(self.value(t)) }
  }

  /// Reverses the animation.
  public var reversed: Animation<A> {
    return Animation(duration: self.duration) { t in
      return self.value(1 - t)
    }
  }

  /// Sequences two animations.
  public static func * (lhs: Animation, rhs: Animation) -> Animation {
    let sum = lhs.duration + rhs.duration
    let ratio = lhs.duration / sum

    return Animation(duration: sum) { t in
      (t <= ratio && lhs.duration != 0)
        ? lhs.value(t / ratio)
        : rhs.value((t - ratio) / (1 - ratio))
    }
  }

  /// Runs two animations in paralllel. If one is longer than the other, the shorter one will stop at it's
  /// last value until the longer one finishes.
  public static func + <B> (lhs: Animation, rhs: Animation<B>) -> Animation<(A, B)> {
    let newDuration = max(lhs.duration, rhs.duration)
    let ratio = newDuration / lhs.duration

    return .init(duration: newDuration) { t in
      let a = lhs.value(min(1, t * ratio))
      let b = rhs.value(min(1, t * ratio))
      return (a, b)
    }
  }

  /// An animation of zero duration that does nothing. The `.value()` function of this animation should
  /// never be called. In general, zero duration animations should just be skipped.
  public static var empty: Animation {
    return .init(duration: 0) { _ in fatalError() }
  }

  /// Repeats this animation `count` times.
  public func repeating(count: Int) -> Animation {
    let doubleCount = Double(count)
    return Animation(duration: self.duration * doubleCount) { t in
      return self.value((t * doubleCount).truncatingRemainder(dividingBy: 1))
    }
  }

  /// Run this animation and then runs its reverse.
  public var looped: Animation {
    return self * self.reversed
  }

  /// Delays this animation by the amount specified.
  public func delayed(by delay: CFAbsoluteTime) -> Animation {
    return const(value: self.start, duration: delay) * self
  }


  /// Experimental: Chris is a fan of this function, but I don't quite understand it yet. It kinda lets you
  /// change a new animation onto an existing one by giving the next animation the final value of the
  // previous.
  public func andThen(_ rhs: @escaping (A) -> Animation) -> Animation {
    return self * rhs(self.end)
  }
}

/// Creates a constant animation that stays at a value for all time.
public func const<A>(value: A, duration: CFAbsoluteTime) -> Animation<A> {
  return Animation(duration: duration, value: { _ in value })
}
