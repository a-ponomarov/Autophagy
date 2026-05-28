
import Foundation
import SwiftData
import Testing
@testable import Autophagy

@MainActor
@Suite("TrackerViewModel")
struct TrackerViewModelTests {

  @Test("Idle duration change persists selection")
  func idleDurationChangePersistsSelection() throws {
    let harness = try ViewModelHarness()
    let viewModel = try harness.requiredViewModel()

    viewModel.updateDuration(seconds: 30 * 60)

    #expect(viewModel.status == .idle)
    #expect(viewModel.plannedDuration == 30 * 60)
    #expect(harness.preferences.selectedDurationSeconds == 30 * 60)
  }

  @Test("Idle duration change clamps selection to maximum")
  func idleDurationChangeClampsSelectionToMaximum() throws {
    let harness = try ViewModelHarness()
    let viewModel = try harness.requiredViewModel()

    viewModel.updateDuration(hours: DurationDefaults.maximumHours + 1)

    let maximumSeconds = DurationDefaults.maximumDurationSeconds
    #expect(viewModel.plannedDuration == TimeInterval(maximumSeconds))
    #expect(harness.preferences.selectedDurationSeconds == maximumSeconds)
  }

  @Test("Countdown start keeps selected duration up to 23 hours")
  func countdownStartKeepsSelectedDurationUpTo23Hours() async throws {
    let harness = try ViewModelHarness()
    let viewModel = try harness.requiredViewModel()
    let durationSeconds = DurationDefaults.seconds(hours: 23)
    viewModel.updateDuration(seconds: durationSeconds)

    await viewModel.start()

    #expect(viewModel.status == .running)
    #expect(viewModel.plannedDuration == TimeInterval(durationSeconds))
    #expect(viewModel.remainingDuration == TimeInterval(durationSeconds))
    #expect(harness.store.loadActiveSession()?.plannedDurationSeconds == durationSeconds)
    #expect(
      harness.alarmCoordinator.scheduledCountdownDuration == TimeInterval(durationSeconds)
    )
    #expect(
      harness.alarmCoordinator.scheduledCountdownPlannedDuration == TimeInterval(durationSeconds)
    )
  }

  @Test("Countdown start subtracts two seconds above 23 hours")
  func countdownStartSubtractsTwoSecondsAbove23Hours() async throws {
    let harness = try ViewModelHarness()
    let viewModel = try harness.requiredViewModel()
    let selectedDurationSeconds = DurationDefaults.seconds(hours: 24)
    let startedDurationSeconds = selectedDurationSeconds - 2
    viewModel.updateDuration(seconds: selectedDurationSeconds)

    await viewModel.start()

    #expect(viewModel.status == .running)
    #expect(viewModel.plannedDuration == TimeInterval(startedDurationSeconds))
    #expect(viewModel.remainingDuration == TimeInterval(startedDurationSeconds))
    #expect(harness.store.loadActiveSession()?.plannedDurationSeconds == startedDurationSeconds)
    #expect(
      harness.alarmCoordinator.scheduledCountdownDuration == TimeInterval(startedDurationSeconds)
    )
    #expect(
      harness.alarmCoordinator.scheduledCountdownPlannedDuration
        == TimeInterval(startedDurationSeconds)
    )
  }

  @Test("Countdown start presents alarm permission alert when authorization is denied")
  func countdownStartPresentsAlarmPermissionAlertWhenAuthorizationIsDenied() async throws {
    let harness = try ViewModelHarness()
    let viewModel = try harness.requiredViewModel()
    harness.alarmCoordinator.scheduleResult = .authorizationDenied

    await viewModel.start()

    #expect(viewModel.status == .idle)
    #expect(viewModel.isAlarmPermissionAlertPresented)
    #expect(harness.store.loadActiveSession() == nil)
  }

  @Test("Refresh completes expired running session")
  func refreshCompletesExpiredRunningSession() async throws {
    let harness = try ViewModelHarness()
    let viewModel = try harness.requiredViewModel()
    viewModel.updateDuration(seconds: 60)
    await viewModel.start()

    let startedAt = try #require(viewModel.startedAt)
    viewModel.refreshTimer(now: startedAt.addingTimeInterval(61))

    let completed = harness.store.fetchCompletedSessions()
    #expect(viewModel.status == .idle)
    #expect(completed.count == 1)
    #expect(completed.first?.endedAt == startedAt.addingTimeInterval(60))
    #expect(harness.alarmCoordinator.stopCount == 0)
  }

  @Test("Load completes expired persisted session at planned end")
  func loadCompletesExpiredPersistedSessionAtPlannedEnd() throws {
    let harness = try ViewModelHarness(makeViewModel: false)
    let startedAt = Date(timeIntervalSinceNow: -120)
    let plannedEnd = startedAt.addingTimeInterval(60)
    _ = harness.store.startSessionIfNeeded(
      durationSeconds: 60,
      startedAt: startedAt
    )

    let viewModel = harness.makeViewModel()

    let completed = harness.store.fetchCompletedSessions()
    #expect(viewModel.status == .idle)
    #expect(completed.count == 1)
    #expect(completed.first?.endedAt == plannedEnd)
  }

  @Test("Running duration change is ignored")
  func runningDurationChangeIsIgnored() async throws {
    let harness = try ViewModelHarness()
    let viewModel = try harness.requiredViewModel()
    viewModel.updateDuration(seconds: 120)
    await viewModel.start()

    viewModel.updateDuration(seconds: 240)

    #expect(viewModel.status == .running)
    #expect(viewModel.plannedDuration == 120)
    #expect(harness.store.loadActiveSession()?.plannedDurationSeconds == 120)
  }

}

@MainActor
private struct ViewModelHarness {

  let container: ModelContainer
  let store: SessionStore
  var preferences: Preferences
  let alarmCoordinator: MockAlarmCoordinator
  let viewModel: TrackerViewModel?

  init(makeViewModel: Bool = true, now: @escaping () -> Date = Date.init) throws {
    let schema = Schema(versionedSchema: AutophagySchemaV1.self)
    let configuration = ModelConfiguration(
      schema: schema,
      isStoredInMemoryOnly: true
    )
    let container = try ModelContainer(
      for: schema,
      migrationPlan: AutophagyMigrationPlan.self,
      configurations: [configuration]
    )
    let store = SessionStore(modelContext: container.mainContext)
    let userDefaults = try #require(UserDefaults(suiteName: UUID().uuidString))
    let preferences = Preferences(userDefaults: userDefaults)
    preferences.reset()
    let alarmCoordinator = MockAlarmCoordinator()

    self.container = container
    self.store = store
    self.preferences = preferences
    self.alarmCoordinator = alarmCoordinator
    self.viewModel = makeViewModel
      ? TrackerViewModel(
        store: store,
        preferences: preferences,
        alarmCoordinator: alarmCoordinator,
        now: now
      )
      : nil
  }

  func makeViewModel() -> TrackerViewModel {
    TrackerViewModel(
      store: store,
      preferences: preferences,
      alarmCoordinator: alarmCoordinator
    )
  }

  func requiredViewModel() throws -> TrackerViewModel {
    try #require(viewModel)
  }

}

@MainActor
private final class MockAlarmCoordinator: AlarmCoordinating {

  private(set) var stopCount = 0
  private(set) var scheduledCountdownDuration: TimeInterval?
  private(set) var scheduledCountdownPlannedDuration: TimeInterval?
  var scheduleResult = AlarmScheduleResult.scheduled
  var hasAlarm = true

  let alarmUpdates = AsyncStream<Void> { _ in }

  func scheduleCountdown(
    duration: TimeInterval,
    plannedDuration: TimeInterval
  ) async -> AlarmScheduleResult {
    scheduledCountdownDuration = duration
    scheduledCountdownPlannedDuration = plannedDuration
    return scheduleResult
  }

  func cancel() {
    stopCount += 1
    hasAlarm = false
  }

  func hasActiveAlarm() -> Bool {
    hasAlarm
  }

}
