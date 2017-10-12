import CoreGraphics

public let easeIn = _easeIn(2)
public let easeOut = _easeIn(0.5)

public func easeIn(_ c: Double) -> (CFAbsoluteTime) -> CFAbsoluteTime {
  return _easeIn(c)
}

public func easeOut(_ c: Double) -> (CFAbsoluteTime) -> CFAbsoluteTime {
  return _easeIn(1 / c)
}

public func _easeIn(_ c: Double) -> (CFAbsoluteTime) -> CFAbsoluteTime {
  return { pow($0, c) }
}

public let easeInOut = _easeInOut(1)

public func easeInOut(_ c: Double = 1) -> (CFAbsoluteTime) -> CFAbsoluteTime {
  return _easeInOut(c)
}

private func _easeInOut(_ c: Double = 1) -> (CFAbsoluteTime) -> CFAbsoluteTime {
  return { t in expInv(c, t) / (expInv(c, t) + expInv(c, 1.0 - t)) }
}

private func expInv(_ c: Double, _ t: CFAbsoluteTime) -> CFAbsoluteTime {
  return t <= 0 ? 0 : exp(-c / t)
}
