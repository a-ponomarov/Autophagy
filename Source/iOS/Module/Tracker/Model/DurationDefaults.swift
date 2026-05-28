
import Foundation

enum DurationDefaults {

  static let secondsPerHour = 60 * 60
  static let minimumHours = 1
  static let maximumHours = 24
  static let maximumDurationSeconds = maximumHours * secondsPerHour
  static let durationAdjustmentThresholdSeconds = 23 * secondsPerHour
  static let startDurationAdjustmentSeconds = 2
  static let defaultHours = minimumHours
  static let defaultDurationSeconds = defaultHours * secondsPerHour

  static func seconds(hours: Int) -> Int {
    hours * secondsPerHour
  }

  static func clampedSeconds(_ seconds: Int) -> Int {
    min(max(1, seconds), maximumDurationSeconds)
  }

  static func startedDurationSeconds(from seconds: Int) -> Int {
    let durationSeconds = clampedSeconds(seconds)
    guard durationSeconds > durationAdjustmentThresholdSeconds else {
      return durationSeconds
    }

    return max(1, durationSeconds - startDurationAdjustmentSeconds)
  }

}
