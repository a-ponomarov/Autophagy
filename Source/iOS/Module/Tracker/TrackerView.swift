
import SwiftUI
import UIKit

struct TrackerView: View {

  @Environment(\.openURL) private var openURL
  @Environment(\.scenePhase) private var scenePhase
  @Environment(AppCoordinator.self) private var coordinator
  @Environment(TrackerViewModel.self) private var trackerViewModel

  var body: some View {
    GeometryReader { geometry in
      ScrollView {
        VStack(spacing: AppLayout.vInset) {
          header

          PanelView(viewModel: trackerViewModel)
        }
        .padding(.horizontal, AppLayout.cardPadding)
        .frame(maxWidth: .infinity)
        .frame(minHeight: geometry.size.height, alignment: .center)
      }
      .scrollIndicators(.hidden)
    }
    .foregroundStyle(AppColors.textPrimary)
    .onAppear {
      trackerViewModel.refreshSessionState()
    }
    .onChange(of: scenePhase) { _, phase in
      guard phase == .active else { return }
      trackerViewModel.refreshSessionState()
    }
    .alert(
      String.alarmPermissionTitle,
      isPresented: alarmPermissionAlertBinding
    ) {
      Button(String.done, role: .cancel) { }
      Button(String.alarmPermissionSettings) {
        openAppSettings()
      }
    } message: {
      Text(String.alarmPermissionMessage)
    }
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          coordinator.presentSettings()
        } label: {
          Image(systemName: "gearshape")
        }
        .accessibilityLabel(String.settingsTitle)
      }
    }
  }

  private var header: some View {
    Text("\(String.trackerTitle) \(String.trackerDurationHours(selectedDurationHours))")
      .font(.largeTitle)
      .bold()
      .multilineTextAlignment(.trailing)
      .lineLimit(1)
      .minimumScaleFactor(0.7)
      .frame(maxWidth: .infinity, alignment: .trailing)
  }

  private var selectedDurationHours: Int {
    let secondsPerHour = TimeInterval(DurationDefaults.secondsPerHour)
    return Int((trackerViewModel.plannedDuration / secondsPerHour).rounded())
  }

  private var alarmPermissionAlertBinding: Binding<Bool> {
    Binding(
      get: { trackerViewModel.isAlarmPermissionAlertPresented },
      set: { trackerViewModel.isAlarmPermissionAlertPresented = $0 }
    )
  }

  private func openAppSettings() {
    guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
    openURL(settingsURL)
  }

}
