import CoreGraphics

// Nice defaults for easing in, out and in+out.
public let easeIn = _easeIn(2)
public let easeOut = _easeIn(0.5)
public let easeInOut = _easeInOut(1)

// Ease in with a parameter. The larger the value of `c` the more intense the ease in.
public func easeIn(_ c: Double) -> (CFAbsoluteTime) -> CFAbsoluteTime {
  return _easeIn(c)
}

// Ease out with a parameter. The larger the value of `c` the more intense the ease out.
public func easeOut(_ c: Double) -> (CFAbsoluteTime) -> CFAbsoluteTime {
  return _easeIn(1 / c)
}

// Ease in+out with a parameter. The larger the value of `c` the more intense the ease in+out.
public func easeInOut(_ c: Double = 1) -> (CFAbsoluteTime) -> CFAbsoluteTime {
  return _easeInOut(c)
}

// private

private func _easeIn(_ c: Double) -> (CFAbsoluteTime) -> CFAbsoluteTime {
  return { 1 - pow(1 - $0, 1/c) }
}

private func _easeInOut(_ c: Double = 1) -> (CFAbsoluteTime) -> CFAbsoluteTime {
  return { t in expInv(c, t) / (expInv(c, t) + expInv(c, 1.0 - t)) }
}

private func expInv(_ c: Double, _ t: CFAbsoluteTime) -> CFAbsoluteTime {
  return t <= 0 ? 0 : exp(-c / t)
}

