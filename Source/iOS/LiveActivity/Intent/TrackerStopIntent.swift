
import AlarmKit
import AppIntents
import Foundation

struct TrackerStopIntent: LiveActivityIntent {

  static let title: LocalizedStringResource = "Stop"
  static let description = IntentDescription("Stop a tracker session")
  static let openAppWhenRun = true

  @Parameter(title: "alarmID")
  var alarmID: String

  init() {
    alarmID = ""
  }

  init(alarmID: String) {
    self.alarmID = alarmID
  }

  func perform() async throws -> some IntentResult {
    guard let alarmID = UUID(uuidString: alarmID) else {
      return .result()
    }

    try AlarmManager.shared.cancel(id: alarmID)
    return .result()
  }

}
