
import Foundation
import os
import SwiftData

@MainActor
final class SessionStore {

  private let modelContext: ModelContext
  private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "app",
    category: "SessionStore"
  )

  init(modelContext: ModelContext) {
    self.modelContext = modelContext
  }

  func loadActiveSession() -> SessionModel? {
    reconcileActiveSessions()
  }

  func startSessionIfNeeded(
    durationSeconds: Int,
    startedAt: Date
  ) -> SessionModel {
    if let activeSession = loadActiveSession() {
      return activeSession
    }

    let session = SessionModel(
      plannedDurationSeconds: max(1, durationSeconds),
      startedAt: startedAt
    )
    modelContext.insert(session)
    save()
    return session
  }

  func completeSession(_ session: SessionModel, endedAt: Date) {
    session.endedAt = endedAt
    save()
  }

  func deleteSession(id: UUID) {
    var descriptor = FetchDescriptor<SessionModel>(
      predicate: #Predicate { $0.id == id }
    )
    descriptor.fetchLimit = 1

    do {
      guard let session = try modelContext.fetch(descriptor).first else { return }
      modelContext.delete(session)
      save()
    } catch {
      logger.error("Unable to delete tracker session: \(error.localizedDescription)")
    }
  }

  func fetchCompletedSessions() -> [SessionModel] {
    let descriptor = FetchDescriptor<SessionModel>(
      predicate: #Predicate { $0.endedAt != nil },
      sortBy: [SortDescriptor(\.endedAt, order: .reverse)]
    )

    do {
      return try modelContext.fetch(descriptor)
    } catch {
      logger.error("Unable to fetch completed tracker sessions: \(error.localizedDescription)")
      return []
    }
  }

  private func reconcileActiveSessions() -> SessionModel? {
    let activeSessions = fetchActiveSessions()
    guard let latestSession = activeSessions.first else { return nil }

    for session in activeSessions.dropFirst() {
      let plannedEnd = session.startedAt.addingTimeInterval(
        TimeInterval(session.plannedDurationSeconds)
      )
      session.endedAt = min(latestSession.startedAt, plannedEnd)
    }

    save()
    return latestSession
  }

  private func fetchActiveSessions() -> [SessionModel] {
    let descriptor = FetchDescriptor<SessionModel>(
      predicate: #Predicate { $0.endedAt == nil },
      sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
    )

    do {
      return try modelContext.fetch(descriptor)
    } catch {
      logger.error("Unable to fetch active tracker sessions: \(error.localizedDescription)")
      return []
    }
  }

  private func save() {
    guard modelContext.hasChanges else { return }

    do {
      try modelContext.save()
    } catch {
      logger.error("Unable to save tracker data: \(error.localizedDescription)")
    }
  }

}
