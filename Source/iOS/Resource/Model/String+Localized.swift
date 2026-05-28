
import Foundation

extension String {

  // MARK: - Common

  static let done = String(localized: "Done")

  // MARK: - Permissions

  static let alarmPermissionTitle = String(localized: "Alarm permission required")
  static let alarmPermissionMessage = String(
    localized: "Allow alarms in Settings to start a fasting timer."
  )
  static let alarmPermissionSettings = String(localized: "Open Settings")

  // MARK: - Settings

  static let settingsTitle = String(localized: "Settings")
  static let settingsSupport = String(localized: "Contact Support")
  static let settingsPrivacyPolicy = String(localized: "Privacy Policy")
  static let settingsSourceCode = String(localized: "Source Code")

  // MARK: - Tracker

  static let trackerTitle = AppConstants.appName
  static let trackerStart = String(localized: "Start fast")
  static let trackerEnd = String(localized: "End")
  static let history = String(localized: "History")
  static let historyEmpty = String(localized: "No fasts yet")
  static let trackerSummaryTotal = String(localized: "Total tracker time")
  static let trackerSummaryFastCount = String(localized: "Fasts")
  static let trackerSummaryNoDateRange = String(localized: "No dates yet")
  static let trackerEnds = String(localized: "Ends")
  static let trackerDuration = String(localized: "Duration")
  static let trackerElapsed = String(localized: "Elapsed")

  static func trackerDurationHours(_ hours: Int) -> String {
    String.localizedStringWithFormat(String(localized: "%lldh"), Int64(hours))
  }

}
