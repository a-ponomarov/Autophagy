
import Foundation
import SwiftData
import Testing
@testable import Autophagy

@MainActor
@Suite("SessionStore")
struct SessionStoreTests {

  @Test("New store has no active session")
  func newStoreHasNoActiveSession() throws {
    let harness = try StoreHarness()

    #expect(harness.store.loadActiveSession() == nil)
  }

  @Test("Start and complete session moves it to history")
  func startAndCompleteSessionMovesItToHistory() throws {
    let harness = try StoreHarness()
    let startedAt = Date(timeIntervalSince1970: 1_000)
    let endedAt = startedAt.addingTimeInterval(3_600)

    let session = harness.store.startSessionIfNeeded(
      durationSeconds: 3_600,
      startedAt: startedAt
    )
    harness.store.completeSession(session, endedAt: endedAt)

    let completed = harness.store.fetchCompletedSessions()
    #expect(completed.count == 1)
    #expect(completed.first?.id == session.id)
    #expect(completed.first?.endedAt == endedAt)
    #expect(completed.first?.plannedDurationSeconds == 3_600)
    #expect(harness.store.loadActiveSession() == nil)
  }

  @Test("Delete removes completed session")
  func deleteRemovesCompletedSession() throws {
    let harness = try StoreHarness()
    let startedAt = Date(timeIntervalSince1970: 2_000)
    let session = harness.store.startSessionIfNeeded(
      durationSeconds: 1_800,
      startedAt: startedAt
    )
    harness.store.completeSession(session, endedAt: startedAt.addingTimeInterval(1_800))

    harness.store.deleteSession(id: session.id)

    #expect(harness.store.fetchCompletedSessions().isEmpty)
  }

  @Test("Active session reconciles older active sessions")
  func activeSessionReconcilesOlderActiveSessions() throws {
    let harness = try StoreHarness()
    let oldStartedAt = Date(timeIntervalSince1970: 1_000)
    let latestStartedAt = oldStartedAt.addingTimeInterval(300)
    let oldSession = SessionModel(
      plannedDurationSeconds: 3_600,
      startedAt: oldStartedAt
    )
    let latestSession = SessionModel(
      plannedDurationSeconds: 7_200,
      startedAt: latestStartedAt
    )
    harness.container.mainContext.insert(oldSession)
    harness.container.mainContext.insert(latestSession)
    try harness.container.mainContext.save()

    let activeSession = harness.store.loadActiveSession()
    let completedSessions = harness.store.fetchCompletedSessions()

    #expect(activeSession?.id == latestSession.id)
    #expect(completedSessions.count == 1)
    #expect(completedSessions.first?.id == oldSession.id)
    #expect(completedSessions.first?.endedAt == latestStartedAt)
  }

  @Test("Active session reconciliation does not extend an old planned end")
  func activeSessionReconciliationDoesNotExtendOldPlannedEnd() throws {
    let harness = try StoreHarness()
    let oldStartedAt = Date(timeIntervalSince1970: 1_000)
    let oldPlannedEnd = oldStartedAt.addingTimeInterval(60)
    let latestStartedAt = oldStartedAt.addingTimeInterval(300)
    let oldSession = SessionModel(
      plannedDurationSeconds: 60,
      startedAt: oldStartedAt
    )
    let latestSession = SessionModel(
      plannedDurationSeconds: 7_200,
      startedAt: latestStartedAt
    )
    harness.container.mainContext.insert(oldSession)
    harness.container.mainContext.insert(latestSession)
    try harness.container.mainContext.save()

    _ = harness.store.loadActiveSession()

    #expect(harness.store.fetchCompletedSessions().first?.endedAt == oldPlannedEnd)
  }

  @Test("Start session returns existing active session")
  func startSessionReturnsExistingActiveSession() throws {
    let harness = try StoreHarness()
    let firstSession = harness.store.startSessionIfNeeded(
      durationSeconds: 1_800,
      startedAt: Date(timeIntervalSince1970: 1_000)
    )
    let secondSession = harness.store.startSessionIfNeeded(
      durationSeconds: 3_600,
      startedAt: Date(timeIntervalSince1970: 2_000)
    )

    #expect(secondSession.id == firstSession.id)
    let activeSessions = try harness.fetchActiveSessions()
    #expect(activeSessions.count == 1)
  }

}

@MainActor
private struct StoreHarness {

  let container: ModelContainer
  let store: SessionStore

  init() throws {
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

    self.container = container
    self.store = SessionStore(modelContext: container.mainContext)
  }

  func fetchActiveSessions() throws -> [SessionModel] {
    let descriptor = FetchDescriptor<SessionModel>(
      predicate: #Predicate { $0.endedAt == nil }
    )
    return try container.mainContext.fetch(descriptor)
  }

}
