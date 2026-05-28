
import Foundation
import SwiftUI

/// Drives the tracker screen: owns presentation state, coordinates the alarm,
/// and persists the active session through `SessionStore`.
@MainActor
@Observable
final class TrackerViewModel {

  var plannedDuration: TimeInterval = TimeInterval(DurationDefaults.defaultDurationSeconds)
  var remainingDuration: TimeInterval = TimeInterval(DurationDefaults.defaultDurationSeconds)
  var status: Status = .idle
  var startedAt: Date?
  var endsAt: Date?
  var isAlarmPermissionAlertPresented = false

  @ObservationIgnored private let store: SessionStore
  @ObservationIgnored private let preferences: Preferences
  @ObservationIgnored private let alarmCoordinator: AlarmCoordinating
  @ObservationIgnored private let now: () -> Date
  @ObservationIgnored private let onSessionFinished: () -> Void
  @ObservationIgnored private var alarmObservationTask: Task<Void, Never>?
  @ObservationIgnored private var activeSession: SessionModel?

  init(
    store: SessionStore,
    preferences: Preferences,
    alarmCoordinator: AlarmCoordinating,
    now: @escaping () -> Date = Date.init,
    onSessionFinished: @escaping () -> Void = {}
  ) {
    self.store = store
    self.preferences = preferences
    self.alarmCoordinator = alarmCoordinator
    self.now = now
    self.onSessionFinished = onSessionFinished
    loadPersistedState()
    observeAlarmUpdates()
    refreshSessionState()
  }

  deinit {
    alarmObservationTask?.cancel()
  }

  func updateDuration(hours: Int) {
    updateDuration(seconds: DurationDefaults.seconds(hours: hours))
  }

  func updateDuration(seconds: Int) {
    guard status == .idle else { return }

    let seconds = TimeInterval(DurationDefaults.clampedSeconds(seconds))
    plannedDuration = seconds
    remainingDuration = seconds
    preferences.selectedDurationSeconds = Int(seconds.rounded())
  }

  func stop() {
    complete(reason: .manual)
  }

  func refreshSessionState() {
    refreshTimer()
    synchronizeWithAlarmManager()
  }

  func refreshTimer(now date: Date? = nil) {
    guard status == .running else { return }

    updateRemainingDuration(now: date ?? now())
    if remainingDuration <= 0 {
      complete(reason: .expired)
    }
  }

  func remainingDuration(at date: Date) -> TimeInterval {
    guard status == .running, let endsAt else { return remainingDuration }
    return max(0, endsAt.timeIntervalSince(date))
  }

  func elapsedDuration(at date: Date) -> TimeInterval {
    guard status == .running, let startedAt else { return 0 }
    return max(0, date.timeIntervalSince(startedAt))
  }

  func start() async {
    guard status == .idle else { return }

    let startDate = now()
    let plannedDuration = TimeInterval(
      DurationDefaults.startedDurationSeconds(
        from: Int(plannedDuration.rounded())
      )
    )
    let scheduleResult = await alarmCoordinator.scheduleCountdown(
      duration: plannedDuration,
      plannedDuration: plannedDuration
    )
    switch scheduleResult {
    case .scheduled:
      break
    case .authorizationDenied:
      isAlarmPermissionAlertPresented = true
      return
    case .failed:
      return
    }

    let endDate = startDate.addingTimeInterval(plannedDuration)
    startedAt = startDate
    endsAt = endDate
    self.plannedDuration = plannedDuration
    remainingDuration = plannedDuration
    status = .running

    activeSession = store.startSessionIfNeeded(
      durationSeconds: Int(plannedDuration.rounded()),
      startedAt: startDate
    )
  }

  private func observeAlarmUpdates() {
    alarmObservationTask?.cancel()
    alarmObservationTask = Task { [weak self] in
      guard let self else { return }

      for await _ in alarmCoordinator.alarmUpdates {
        synchronizeWithAlarmManager()
      }
    }
  }

  private func synchronizeWithAlarmManager() {
    guard status == .running else { return }

    guard alarmCoordinator.hasActiveAlarm() else {
      complete(reason: .externalStop)
      return
    }
  }

  private func complete(reason: CompletionReason) {
    switch reason {
    case .manual:
      finalizeSession(endedAt: now(), shouldStopAlarm: true)
    case .expired:
      finalizeSession(endedAt: endsAt ?? now(), shouldStopAlarm: false)
    case .externalStop:
      let currentDate = now()
      updateRemainingDuration(now: currentDate)
      let endedAt = remainingDuration <= 0 ? (endsAt ?? currentDate) : currentDate
      finalizeSession(endedAt: endedAt, shouldStopAlarm: false)
    }
  }

  private func finalizeSession(endedAt: Date, shouldStopAlarm: Bool) {
    if shouldStopAlarm {
      alarmCoordinator.cancel()
    }

    if let activeSession, status != .idle {
      store.completeSession(activeSession, endedAt: endedAt)
      self.activeSession = nil
      onSessionFinished()
    }

    status = .idle
    startedAt = nil
    endsAt = nil
    remainingDuration = plannedDuration
  }

  private func loadPersistedState() {
    let selectedDurationSeconds = DurationDefaults.clampedSeconds(
      preferences.selectedDurationSeconds
    )
    preferences.selectedDurationSeconds = selectedDurationSeconds
    plannedDuration = TimeInterval(selectedDurationSeconds)
    remainingDuration = plannedDuration

    guard let session = store.loadActiveSession() else {
      return
    }

    activeSession = session
    plannedDuration = TimeInterval(session.plannedDurationSeconds)
    startedAt = session.startedAt
    endsAt = session.startedAt.addingTimeInterval(plannedDuration)
    updateRemainingDuration(now: now())
    status = .running

    if remainingDuration <= 0 {
      complete(reason: .expired)
    }
  }

  private func updateRemainingDuration(now: Date) {
    guard let endsAt else { return }
    remainingDuration = max(0, endsAt.timeIntervalSince(now))
  }

}
