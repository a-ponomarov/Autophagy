
import SwiftUI

struct PanelView: View {

  let viewModel: TrackerViewModel

  var body: some View {
    VStack(spacing: AppLayout.spacing * 4) {
      TimelineView(.periodic(from: .now, by: 1)) { timeline in
        TimerDial(
          timeText: timeText(at: timeline.date),
          elapsedText: elapsedText(at: timeline.date),
          sessionText: sessionText,
          ringProgress: ringProgress(at: timeline.date)
        )
        .padding(.horizontal, AppLayout.spacing * 8)
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .onChange(of: timeline.date) { _, date in
          viewModel.refreshTimer(now: date)
        }
      }

      durationControls
        .padding(.horizontal, AppLayout.spacing)

      ActionRow(
        canStop: canStop,
        canStart: canStart,
        onStop: viewModel.stop,
        onStart: {
          Task { await viewModel.start() }
        }
      )
    }
    .frame(maxWidth: .infinity)
  }

  private var durationControls: some View {
    VStack(spacing: AppLayout.spacing * 2) {
      Stepper(
        value: Binding(
          get: { selectedDurationHours },
          set: { viewModel.updateDuration(hours: $0) }
        ),
        in: DurationDefaults.minimumHours...DurationDefaults.maximumHours,
        step: 1
      ) { }
      .labelsHidden()
      .disabled(!canUpdateDuration)

      durationSlider
        .disabled(!canUpdateDuration)
    }
  }

  private var durationSlider: some View {
    let minimumHours = Double(DurationDefaults.minimumHours)
    let maximumHours = Double(DurationDefaults.maximumHours)
    return Slider(
      value: Binding(
        get: { Double(selectedDurationHours) },
        set: { viewModel.updateDuration(hours: Int($0.rounded())) }
      ),
      in: minimumHours...maximumHours,
      step: 1
    )
    .tint(AppColors.accent)
    .accessibilityLabel(String.trackerDuration)
  }

  private var selectedDurationHours: Int {
    let secondsPerHour = TimeInterval(DurationDefaults.secondsPerHour)
    let hours = Int((viewModel.plannedDuration / secondsPerHour).rounded())
    let minimum = DurationDefaults.minimumHours
    let maximum = DurationDefaults.maximumHours
    return min(maximum, max(minimum, hours))
  }

  private var canUpdateDuration: Bool {
    viewModel.status == .idle
  }

  private var canStop: Bool {
    viewModel.status != .idle
  }

  private var canStart: Bool {
    viewModel.status == .idle
  }

  private func ringProgress(at date: Date) -> CGFloat {
    switch viewModel.status {
    case .idle:
      return 1
    case .running:
      let rawProgress = viewModel.remainingDuration(at: date) / max(viewModel.plannedDuration, 1)
      return max(0, min(1, rawProgress))
    }
  }

  private func timeText(at date: Date) -> String {
    viewModel.remainingDuration(at: date).durationText
  }

  private func elapsedText(at date: Date) -> String? {
    guard viewModel.status == .running else { return nil }
    return viewModel.elapsedDuration(at: date).durationText
  }

  private var sessionText: String? {
    guard viewModel.status == .running,
          let endsAt = viewModel.endsAt else { return nil }

    let endText = endsAt.formatted(date: .abbreviated, time: .shortened)
    return "\(String.trackerEnds) \(endText)"
  }

}
