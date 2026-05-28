
import Foundation

/// Abstracts the alarm subsystem so feature view models can be tested without `AlarmKit`.
protocol AlarmCoordinating: AnyObject {

  var alarmUpdates: AsyncStream<Void> { get }

  func scheduleCountdown(
    duration: TimeInterval,
    plannedDuration: TimeInterval
  ) async -> AlarmScheduleResult
  func cancel()
  func hasActiveAlarm() -> Bool

}
