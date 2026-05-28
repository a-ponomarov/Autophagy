
import SwiftUI

enum LiveActivityStyle {

  static let accent = Color(red: 0.63, green: 0.63, blue: 0.63)
  static let tint = accent
  static let textPrimary = Color.black
  static let textOnDark = Color.white
  static let bodyMedium = Font.system(size: 17, weight: .medium).monospacedDigit()

  static func bold(size: CGFloat) -> Font {
    .system(size: size, weight: .bold).monospacedDigit()
  }

  static func medium(size: CGFloat) -> Font {
    .system(size: size, weight: .medium).monospacedDigit()
  }

}
