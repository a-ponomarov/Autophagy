
import SwiftUI

/// Owns app-level navigation and modal presentation state.
@MainActor
@Observable
final class AppCoordinator {

  enum Tab: Hashable {

    case tracker
    case history

  }

  enum Sheet: String, Identifiable {

    case settings

    var id: String { rawValue }

  }

  var selectedTab: Tab = .tracker
  var trackerPath = NavigationPath()
  var historyPath = NavigationPath()
  var presentedSheet: Sheet?

  func presentSettings() {
    presentedSheet = .settings
  }

  func dismissSheet() {
    presentedSheet = nil
  }

}
