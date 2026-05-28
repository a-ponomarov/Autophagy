
import Foundation
import SwiftData

enum AutophagySchemaV1: VersionedSchema {

  static var versionIdentifier: Schema.Version {
    Schema.Version(1, 0, 0)
  }

  static var models: [any PersistentModel.Type] {
    [Session.self]
  }

  @Model
  final class Session {

    var id = UUID()
    var plannedDurationSeconds = 0
    var startedAt = Date()
    var endedAt: Date?

    init(
      id: UUID = UUID(),
      plannedDurationSeconds: Int,
      startedAt: Date,
      endedAt: Date? = nil
    ) {
      self.id = id
      self.plannedDurationSeconds = max(1, plannedDurationSeconds)
      self.startedAt = startedAt
      self.endedAt = endedAt
    }

    var duration: TimeInterval? {
      guard let endedAt else { return nil }
      return endedAt.timeIntervalSince(startedAt)
    }

  }

}

enum AutophagyMigrationPlan: SchemaMigrationPlan {

  static var schemas: [any VersionedSchema.Type] {
    [AutophagySchemaV1.self]
  }

  static var stages: [MigrationStage] {
    []
  }

}

typealias SessionModel = AutophagySchemaV1.Session
