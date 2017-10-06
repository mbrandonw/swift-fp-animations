import Foundation
import AnimationsCore
import UIKit

let step1 = linear(from: 0, to: 200, in: 1)
let step2 = linear(from: 50, to: 200, in: 3)
let step3 = linear(from: 200, to: 300, in: 1)
let sequenced = step1 * step2 * step3

extension CGAffineTransform {
  // helper for setting the absolute rotation of a CGAffineTransform.
  // It would prob be better to define a type with just rotation and translation
  // and then derive `transform` from it.
  var rotation: CGFloat {
    // boy i wish swift allowed just setters
    get { return 0 }
    set {
      var result = CGAffineTransform(rotationAngle: newValue)
      result.tx = self.tx
      result.ty = self.ty
      self = result
    }
  }
}

sequenced.value(0)
sequenced.value(0.2)
sequenced.value(0.4)
sequenced.value(0.6)
sequenced.value(0.8)
sequenced.value(1)

let paralleled = step1 + step2

paralleled.value(0)
paralleled.value(0.2)
paralleled.value(0.4)
paralleled.value(0.6)
paralleled.value(0.8)
paralleled.value(1)

// proof of associativity:
let assoc1 = step1 * (step2 * step3)
let assoc2 = (step1 * step2) * step3
assoc1.value(0.5)
assoc2.value(0.5)
assoc1.value(0.25)
assoc2.value(0.25)
assoc1.value(0.75)
assoc2.value(0.75)

// proof of non-distributivity:

// first this doesn't compile since `+` goes `a -> b -> (a, b)`
//(step1 * (step2 + step3)).value(0.5)
//(step1 * step2 + step1 * step3)).value(0.5)

// and then if we flip the roles of `+` and `*` we have:
(step1 + (step2 * step3)).value(0.5)
((step1 + step2) * (step1 + step3)).value(0.5)
// ^ values not equal



let redSquare = UIView(frame: .init(x: 0, y: 0, width: 100, height: 100))
redSquare.backgroundColor = .red

let blueSquare = UIView(frame: .init(x: 0, y: 200, width: 100, height: 100))
blueSquare.backgroundColor = .blue

let container = UIView(frame: .init(x: 0, y: 0, width: 400, height: 400))
container.backgroundColor = .white
container.addSubview(redSquare)
container.addSubview(blueSquare)

import PlaygroundSupport

PlaygroundPage.current.liveView = container
PlaygroundPage.current.needsIndefiniteExecution = true

let driver = Drive(maxSteps: 500)

// BUMP FUNCTIONS!
func f(_ t: CFAbsoluteTime) -> CFAbsoluteTime {
  return t <= 0 ? 0 : exp(-1.0 / t)
}
func g(_ t: CFAbsoluteTime) -> CFAbsoluteTime {
  return f(t) / (f(t) + f(1-t))
}

let redAnimation =
  // move back and forth
  step1
    .transformTime(g)
    .looped
    .delayed(by: 1)
    .repeating(count: Int.max)
    .bind(redSquare, with: \.transform.tx)
    // rotate back and forth
//    + step1.map { $0/20 }.looped.repeating(count: 4).bind(redSquare, with: \.transform.rotation)

let blueAnimation =
  (step1 * step2 * step3).bind(blueSquare, with: \.transform.tx)

let final = redAnimation + blueAnimation

DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
  driver.append(animation: final.map { _ in () })
}




print("✅")




