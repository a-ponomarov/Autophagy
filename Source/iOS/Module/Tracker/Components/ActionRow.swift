
import SwiftUI

struct ActionRow: View {

  private enum Constants {

    static let ctaHeight: CGFloat = 52
    static let cornerRadius: CGFloat = 8

  }

  let canStop: Bool
  let canStart: Bool
  let onStop: () -> Void
  let onStart: () -> Void

  var body: some View {
    HStack(spacing: AppLayout.spacing * 3) {
      if canStop {
        actionButton(
          systemName: "stop.fill",
          accessibilityLabel: String.trackerEnd,
          action: onStop
        )
      }

      if canStart {
        actionButton(
          systemName: "play.fill",
          accessibilityLabel: String.trackerStart,
          action: onStart
        )
      }
    }
  }

  private func actionButton(
    systemName: String,
    accessibilityLabel: String,
    action: @escaping () -> Void
  ) -> some View {
    Button(action: action) {
      Image(systemName: systemName)
        .font(AppFont.button)
        .frame(maxWidth: .infinity)
        .frame(height: Constants.ctaHeight)
        .foregroundStyle(AppColors.background)
        .background(
          RoundedRectangle(cornerRadius: Constants.cornerRadius, style: .continuous)
            .fill(AppColors.accent)
        )
    }
    .buttonStyle(.plain)
    .accessibilityLabel(accessibilityLabel)
  }

}
