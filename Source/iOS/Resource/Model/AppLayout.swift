
import SwiftUI

enum AppLayout {

  // MARK: - Spacing

  static let spacing: CGFloat = 4

  // MARK: - Stroke

  static let stroke: CGFloat = 0.88

  // MARK: - Screen

  static let vInset: CGFloat = 10
  static let cardPadding: CGFloat = 1.6 * vInset
  static let cardRadius: CGFloat = 1.6 * vInset

  static let rowInsets = EdgeInsets(
    top: 0,
    leading: cardPadding,
    bottom: vInset,
    trailing: cardPadding
  )

  static let listRowInsets = EdgeInsets(
    top: 0,
    leading: cardPadding,
    bottom: 0,
    trailing: cardPadding
  )

}
