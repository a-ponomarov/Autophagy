
import SwiftUI

extension Font {

  static func mono(size: CGFloat, weight: Weight) -> Font {
    .system(size: size, weight: weight).monospacedDigit()
  }

  static func bold(size: CGFloat) -> Font {
    mono(size: size, weight: .bold)
  }

  static func semibold(size: CGFloat) -> Font {
    mono(size: size, weight: .semibold)
  }

  static func medium(size: CGFloat) -> Font {
    mono(size: size, weight: .medium)
  }

  static func regular(size: CGFloat) -> Font {
    mono(size: size, weight: .regular)
  }

}
