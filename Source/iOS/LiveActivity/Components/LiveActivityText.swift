
import AlarmKit
import SwiftUI

struct LiveActivityText: View {

  private enum Constants {

    static let lockScreenExpandedFontSize = 34.0
    static let dynamicIslandExpandedFontSize = 26.0
    static let compactFontSize = 14.0
    static let lockScreenExpandedMinimumScaleFactor = 0.61
    static let dynamicIslandExpandedMinimumScaleFactor = 0.58
    static let compactMinimumScaleFactor = 0.58
    static let compactMaxWidth = 46.0
    static let secondsPerHour = 60 * 60

  }

  let state: AlarmPresentationState
  let layout: LiveActivityLayout
  let textColor: Color

  var body: some View {
    Group {
      switch state.mode {
      case .countdown(let countdown):
        Text(timerInterval: Date.now ... countdown.fireDate, countsDown: true)
      case .paused(let paused):
        Text(pausedRemainingText(paused))
      default:
        EmptyView()
      }
    }
    .font(LiveActivityStyle.bold(size: fontSize))
    .monospacedDigit()
    .foregroundStyle(textColor)
    .lineLimit(1)
    .minimumScaleFactor(minimumScaleFactor)
    .frame(maxWidth: maxWidth, alignment: .leading)
  }

  private var fontSize: Double {
    switch layout {
    case .lockScreenExpanded:
      Constants.lockScreenExpandedFontSize
    case .dynamicIslandExpanded:
      Constants.dynamicIslandExpandedFontSize
    case .compact:
      Constants.compactFontSize
    }
  }

  private var minimumScaleFactor: Double {
    switch layout {
    case .lockScreenExpanded:
      Constants.lockScreenExpandedMinimumScaleFactor
    case .dynamicIslandExpanded:
      Constants.dynamicIslandExpandedMinimumScaleFactor
    case .compact:
      Constants.compactMinimumScaleFactor
    }
  }

  private var maxWidth: CGFloat {
    switch layout {
    case .lockScreenExpanded, .dynamicIslandExpanded:
      .infinity
    case .compact:
      Constants.compactMaxWidth
    }
  }

  private func pausedRemainingText(_ paused: AlarmPresentationState.Mode.Paused) -> String {
    let remaining = Duration.seconds(
      paused.totalCountdownDuration - paused.previouslyElapsedDuration
    )
    let pattern: Duration.TimeFormatStyle.Pattern =
      remaining > .seconds(Constants.secondsPerHour) ? .hourMinuteSecond : .minuteSecond
    return remaining.formatted(.time(pattern: pattern))
  }

}
