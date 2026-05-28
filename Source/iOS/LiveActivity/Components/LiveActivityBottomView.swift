
import AlarmKit
import SwiftUI

struct LiveActivityBottomView: View {

  let attributes: AlarmAttributes<TrackerActivityMetadata>
  let state: AlarmPresentationState
  let layout: LiveActivityLayout
  let buttonSizeStyle: LiveActivityButtonSizeStyle
  let textColor: Color

  var body: some View {
    HStack(spacing: 12) {
      LiveActivityText(
        state: state,
        layout: layout,
        textColor: textColor
      )
      .frame(maxWidth: .infinity, alignment: .leading)

      LiveActivityButton(
        configuration: AlarmButton(
          text: LocalizedStringResource("Stop"),
          textColor: .white,
          systemImageName: "stop.fill"
        ),
        intent: TrackerStopIntent(alarmID: state.alarmID.uuidString),
        tint: LiveActivityStyle.accent,
        sizeStyle: buttonSizeStyle
      )

      LiveActivityExpandedLabels(
        attributes: attributes,
        state: state,
        layout: layout,
        textColor: textColor
      )
      .frame(maxWidth: .infinity, alignment: .trailing)
    }
  }

}
