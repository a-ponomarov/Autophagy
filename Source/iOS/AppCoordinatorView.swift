
import SwiftUI

/// Renders the app root from `AppCoordinator` state.
struct AppCoordinatorView: View {

  @Environment(AppCoordinator.self) private var coordinator

  var body: some View {
    @Bindable var coordinator = coordinator

    TabView(selection: $coordinator.selectedTab) {
      NavigationStack(path: $coordinator.trackerPath) {
        TrackerView()
      }
      .tabItem {
        Label(String.trackerTitle, systemImage: "timer")
      }
      .tag(AppCoordinator.Tab.tracker)

      NavigationStack(path: $coordinator.historyPath) {
        HistoryView()
      }
      .tabItem {
        Label(String.history, systemImage: "clock.arrow.circlepath")
      }
      .tag(AppCoordinator.Tab.history)
    }
    .sheet(item: $coordinator.presentedSheet) { sheet in
      switch sheet {
      case .settings:
        SettingsView()
      }
    }
  }

}
