
import AlarmKit
import SwiftUI

struct LiveActivityExpandedLabels: View {

  private enum Constants {

    static let lockScreenExpandedEndDateFontSize = 13.0
    static let dynamicIslandExpandedEndDateFontSize = 11.0

  }

  let attributes: AlarmAttributes<TrackerActivityMetadata>
  let state: AlarmPresentationState
  let layout: LiveActivityLayout
  let textColor: Color

  var body: some View {
    VStack(alignment: .leading, spacing: 3) {
      Text(AppConstants.appName)
        .font(LiveActivityStyle.bodyMedium)
        .foregroundStyle(textColor)
        .lineLimit(1)
        .minimumScaleFactor(0.72)

      if let endDateText {
        Text("\(String(localized: "Ends")) \(endDateText)")
          .font(LiveActivityStyle.medium(size: endDateFontSize))
          .foregroundStyle(textColor.opacity(0.72))
          .lineLimit(1)
          .minimumScaleFactor(0.62)
      }
    }
  }

  private var endDateFontSize: Double {
    switch layout {
    case .lockScreenExpanded:
      Constants.lockScreenExpandedEndDateFontSize
    case .dynamicIslandExpanded, .compact:
      Constants.dynamicIslandExpandedEndDateFontSize
    }
  }

  private var endDateText: String? {
    guard case .countdown(let countdown) = state.mode else { return nil }
    return countdown.fireDate.formatted(date: .abbreviated, time: .shortened)
  }

}
