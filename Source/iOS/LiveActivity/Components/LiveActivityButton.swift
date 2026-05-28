
import AlarmKit
import AppIntents
import SwiftUI

struct LiveActivityButton<IntentType>: View where IntentType: AppIntent {

  let configuration: AlarmButton
  let intent: IntentType
  let tint: Color
  let sizeStyle: LiveActivityButtonSizeStyle

  var body: some View {
    Button(intent: intent) {
      Image(systemName: configuration.systemImageName)
        .font(.system(size: iconSize, weight: .semibold))
        .frame(width: buttonSize, height: buttonSize)
    }
    .buttonStyle(.borderedProminent)
    .buttonBorderShape(.circle)
    .controlSize(.small)
    .tint(tint)
    .accessibilityLabel(Text(configuration.text))
  }

  private var buttonSize: Double {
    switch sizeStyle {
    case .regular:
      30.0
    case .compact:
      26.0
    }
  }

  private var iconSize: Double {
    switch sizeStyle {
    case .regular:
      14.0
    case .compact:
      12.0
    }
  }

}
