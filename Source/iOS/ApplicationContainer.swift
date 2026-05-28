
import Foundation
import SwiftData

/// Composition root that wires long-lived services and feature view models.
@MainActor
final class ApplicationContainer {

  let modelContainer: ModelContainer
  let appCoordinator: AppCoordinator
  let trackerViewModel: TrackerViewModel
  let historyViewModel: HistoryViewModel

  init() {
    do {
      let schema = Schema(versionedSchema: AutophagySchemaV1.self)
      let configuration = ModelConfiguration(
        schema: schema,
        cloudKitDatabase: .none
      )
      let modelContainer = try ModelContainer(
        for: schema,
        migrationPlan: AutophagyMigrationPlan.self,
        configurations: [configuration]
      )
      self.modelContainer = modelContainer
      self.appCoordinator = AppCoordinator()

      let store = SessionStore(modelContext: modelContainer.mainContext)
      let historyViewModel = HistoryViewModel(store: store)
      self.historyViewModel = historyViewModel
      self.trackerViewModel = TrackerViewModel(
        store: store,
        preferences: Preferences(),
        alarmCoordinator: AlarmCoordinator(),
        onSessionFinished: { [weak historyViewModel] in
          historyViewModel?.reloadRecords()
        }
      )
    } catch {
      // SwiftData schema is static and known at compile time, so failure here
      // indicates a corrupted store or unrecoverable migration error.
      fatalError("Unable to initialize SwiftData container: \(error)")
    }
  }

}
