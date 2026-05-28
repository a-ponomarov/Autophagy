
import ActivityKit
import AlarmKit
import SwiftUI
import WidgetKit

struct LiveActivity: Widget {

  var body: some WidgetConfiguration {
    ActivityConfiguration(for: AlarmAttributes<TrackerActivityMetadata>.self) { context in
      LiveActivityView(context: context)
        .activityBackgroundTint(.white)
        .activitySystemActionForegroundColor(LiveActivityStyle.accent)
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.bottom) {
          LiveActivityBottomView(
            attributes: context.attributes,
            state: context.state,
            layout: .dynamicIslandExpanded,
            buttonSizeStyle: .compact,
            textColor: LiveActivityStyle.textOnDark
          )
          .padding(.horizontal, 12)
          .padding(.vertical, 6)
        }
      } compactLeading: {
        LiveActivityProgressView(state: context.state)
      } compactTrailing: {
        LiveActivityText(
          state: context.state,
          layout: .compact,
          textColor: LiveActivityStyle.textOnDark
        )
      } minimal: {
        LiveActivityProgressView(state: context.state)
      }
      .keylineTint(LiveActivityStyle.tint)
    }
  }

}
