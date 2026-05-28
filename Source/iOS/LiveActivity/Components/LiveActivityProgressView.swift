
import AlarmKit
import SwiftUI

struct LiveActivityProgressView: View {

  let state: AlarmPresentationState

  var body: some View {
    Group {
      let hourglass = Image(systemName: "hourglass")
      switch state.mode {
      case .countdown(let countdown):
        ProgressView(
          timerInterval: Date.now ... countdown.fireDate,
          countsDown: true,
          label: { EmptyView() },
          currentValueLabel: { hourglass }
        )
      case .paused(let paused):
        ProgressView(
          value: paused.totalCountdownDuration - paused.previouslyElapsedDuration,
          total: paused.totalCountdownDuration,
          label: { EmptyView() },
          currentValueLabel: { hourglass }
        )
      default:
        EmptyView()
      }
    }
    .progressViewStyle(.circular)
    .foregroundStyle(LiveActivityStyle.tint)
    .tint(LiveActivityStyle.tint)
  }

}
