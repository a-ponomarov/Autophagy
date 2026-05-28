
import SwiftData
import SwiftUI

@main
struct AutophagyApp: App {

  @State private var container = ApplicationContainer()

  var body: some Scene {
    WindowGroup {
      AppCoordinatorView()
        .tint(.white)
        .preferredColorScheme(.dark)
        .environment(container.appCoordinator)
        .environment(container.trackerViewModel)
        .environment(container.historyViewModel)
    }
    .modelContainer(container.modelContainer)
  }

}
