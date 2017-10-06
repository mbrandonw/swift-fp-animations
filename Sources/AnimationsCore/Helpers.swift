import CoreGraphics

public func linear(from a: CGFloat, to b: CGFloat, in duration: CFAbsoluteTime) -> Animation<CGFloat> {
  return Animation(duration: duration) { t in
    a * (1 - CGFloat(t)) + b * CGFloat(t)
  }
}

