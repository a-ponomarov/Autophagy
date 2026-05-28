
import SwiftUI

struct SessionRow: View {

  private enum Constants {

    static let minHeight: CGFloat = 88

  }

  let subtitle: String
  let durationText: String

  var body: some View {
    VStack(spacing: AppLayout.spacing * 2) {
      Text(durationText)
        .font(AppFont.button)
        .monospacedDigit()
        .lineLimit(1)
        .minimumScaleFactor(0.75)
        .foregroundStyle(AppColors.accent)
        .frame(maxWidth: .infinity, alignment: .center)

      Text(subtitle)
        .font(AppFont.caption)
        .foregroundStyle(AppColors.textSecondary)
        .multilineTextAlignment(.center)
        .lineLimit(2)
        .minimumScaleFactor(0.85)
        .frame(maxWidth: .infinity, alignment: .center)
    }
    .padding(.horizontal, AppLayout.cardPadding)
    .padding(.vertical, AppLayout.spacing * 5)
    .frame(maxWidth: .infinity)
    .frame(minHeight: Constants.minHeight)
    .card()
  }

}
