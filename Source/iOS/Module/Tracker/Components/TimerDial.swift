
import SwiftUI

struct TimerDial: View {

  private enum Constants {

    static let ringLineWidth: CGFloat = 18
    static let ringArcLength: CGFloat = 0.75
    static let ringStartAngle = 135.0

  }

  let timeText: String
  let elapsedText: String?
  let sessionText: String?
  let ringProgress: CGFloat

  var body: some View {
    ZStack {
      ringArc
        .stroke(
          AppColors.tint,
          style: StrokeStyle(
            lineWidth: Constants.ringLineWidth,
            lineCap: .round
          )
        )

      progressArc
        .stroke(
          AppColors.accent,
          style: StrokeStyle(
            lineWidth: Constants.ringLineWidth,
            lineCap: .round
          )
        )
        .animation(.linear(duration: 1), value: visibleRingProgress)

      content
        .padding(.horizontal, AppLayout.spacing * 8)
    }
  }

  @ViewBuilder
  private var content: some View {
    if let elapsedText {
      VStack(spacing: AppLayout.spacing * 2) {
        Text(String.trackerElapsed.uppercased())
          .font(AppFont.captionMedium)
          .foregroundStyle(AppColors.accent)
          .lineLimit(1)
          .minimumScaleFactor(0.65)

        Text(elapsedText)
          .font(AppFont.displayMedium)
          .foregroundStyle(AppColors.accent)
          .monospacedDigit()
          .lineLimit(1)
          .minimumScaleFactor(0.45)

        if let sessionText {
          Text(sessionText)
            .font(AppFont.caption)
            .foregroundStyle(AppColors.textSecondary)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.75)
        }
      }
    } else {
      Text(timeText)
        .font(AppFont.displayMedium)
        .foregroundStyle(AppColors.accent)
        .monospacedDigit()
        .lineLimit(1)
        .minimumScaleFactor(0.45)
    }
  }

  private var ringArc: some Shape {
    Circle()
      .trim(from: 0, to: Constants.ringArcLength)
      .rotation(.degrees(Constants.ringStartAngle))
  }

  private var progressArc: some Shape {
    Circle()
      .trim(from: progressStart, to: Constants.ringArcLength)
      .rotation(.degrees(Constants.ringStartAngle))
  }

  private var progressStart: CGFloat {
    Constants.ringArcLength * (1 - visibleRingProgress)
  }

  private var visibleRingProgress: CGFloat {
    min(1, max(0, ringProgress))
  }

}
