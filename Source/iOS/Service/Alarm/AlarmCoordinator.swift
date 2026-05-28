
import AlarmKit
import Foundation
import os
import SwiftUI

/// Schedules and observes the single tracker alarm via `AlarmManager`.
/// The single-alarm assumption keeps the API focused on one fasting session at a time.
final class AlarmCoordinator: AlarmCoordinating {

  private enum Constants {

    /// Stable identifier used to schedule and look up the single tracker alarm.
    static let alarmID = UUID(
      uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0x77, 0x78)
    )

  }

  /// `AlarmManager` is a system singleton without Sendable guarantees; the access pattern
  /// is documented to be safe across actors in Apple's sample code.
  nonisolated(unsafe) private let alarmManager: AlarmManager
  private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "app",
    category: "AlarmCoordinator"
  )

  init(alarmManager: AlarmManager = .shared) {
    self.alarmManager = alarmManager
  }

  var alarmUpdates: AsyncStream<Void> {
    AsyncStream { continuation in
      let task = Task { [alarmManager] in
        for await _ in alarmManager.alarmUpdates {
          continuation.yield(())
        }
        continuation.finish()
      }

      continuation.onTermination = { _ in
        task.cancel()
      }
    }
  }

  func scheduleCountdown(
    duration: TimeInterval,
    plannedDuration: TimeInterval
  ) async -> AlarmScheduleResult {
    let duration = max(1, duration)
    guard await requestAuthorization() else { return .authorizationDenied }

    return await scheduleAlarm(
      configuration: countdownAlarmConfiguration(
        duration: duration,
        plannedDuration: plannedDuration
      )
    )
  }

  func cancel() {
    do {
      try alarmManager.cancel(id: Constants.alarmID)
    } catch {
      logger.error("Unable to cancel tracker alarm: \(error.localizedDescription)")
    }
  }

  func hasActiveAlarm() -> Bool {
    do {
      return try alarmManager.alarms.contains { $0.id == Constants.alarmID }
    } catch {
      logger.error("Unable to fetch tracker alarms: \(error.localizedDescription)")
      return false
    }
  }

  private func scheduleAlarm(
    configuration: AlarmManager.AlarmConfiguration<TrackerActivityMetadata>
  ) async -> AlarmScheduleResult {
    do {
      try await schedule(configuration: configuration)
      return .scheduled
    } catch {
      logger.error("Unable to schedule tracker alarm: \(error.localizedDescription)")
      cancel()

      do {
        try await schedule(configuration: configuration)
        return .scheduled
      } catch {
        logger.error(
          "Unable to schedule tracker alarm after cancel retry: \(error.localizedDescription)"
        )
        return .failed
      }
    }
  }

  private func schedule(
    configuration: sending AlarmManager.AlarmConfiguration<TrackerActivityMetadata>
  ) async throws {
    _ = try await alarmManager.schedule(id: Constants.alarmID, configuration: configuration)
  }

  private func requestAuthorization() async -> Bool {
    do {
      if alarmManager.authorizationState == .notDetermined {
        return try await alarmManager.requestAuthorization() == .authorized
      }
      return alarmManager.authorizationState == .authorized
    } catch {
      logger.error("Unable to request alarm authorization: \(error.localizedDescription)")
      return false
    }
  }

  private func countdownAlarmConfiguration(
    duration: TimeInterval,
    plannedDuration: TimeInterval
  ) -> AlarmManager.AlarmConfiguration<TrackerActivityMetadata> {
    let alert = AlarmPresentation.Alert(
      title: LocalizedStringResource(stringLiteral: AppConstants.appName)
    )
    let countdown = AlarmPresentation.Countdown(
      title: LocalizedStringResource(stringLiteral: AppConstants.appName)
    )
    let attributes = AlarmAttributes(
      presentation: AlarmPresentation(
        alert: alert,
        countdown: countdown
      ),
      metadata: TrackerActivityMetadata(
        duration: plannedDuration
      ),
      tintColor: .white
    )

    return AlarmManager.AlarmConfiguration.timer(
      duration: duration,
      attributes: attributes,
      stopIntent: TrackerStopIntent(alarmID: Constants.alarmID.uuidString)
    )
  }

}
