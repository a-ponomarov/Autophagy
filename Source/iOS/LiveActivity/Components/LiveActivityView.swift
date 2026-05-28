
import ActivityKit
import AlarmKit
import SwiftUI
import WidgetKit

struct LiveActivityView: View {

  private enum Constants {

    static let horizontalPadding: CGFloat = 22
    static let verticalPadding: CGFloat = 14

  }

  let context: ActivityViewContext<AlarmAttributes<TrackerActivityMetadata>>

  var body: some View {
    LiveActivityBottomView(
      attributes: context.attributes,
      state: context.state,
      layout: .lockScreenExpanded,
      buttonSizeStyle: .regular,
      textColor: LiveActivityStyle.textPrimary
    )
    .padding(.horizontal, Constants.horizontalPadding)
    .padding(.vertical, Constants.verticalPadding)
  }

}
