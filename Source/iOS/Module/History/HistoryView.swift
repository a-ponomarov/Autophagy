
import SwiftUI

struct HistoryView: View {

  @Environment(\.scenePhase) private var scenePhase
  @Environment(HistoryViewModel.self) private var historyViewModel

  var body: some View {
    List {
      Text(String.history)
        .font(.largeTitle)
        .bold()
        .frame(maxWidth: .infinity, alignment: .trailing)
        .listRowInsets(AppLayout.rowInsets)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)

      summaryCard
        .listRowInsets(AppLayout.rowInsets)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)

      if historyViewModel.records.isEmpty {
        Text(String.historyEmpty)
          .font(AppFont.subtitle)
          .foregroundStyle(AppColors.textSecondary)
          .frame(maxWidth: .infinity, alignment: .center)
          .listRowInsets(AppLayout.rowInsets)
          .listRowBackground(Color.clear)
          .listRowSeparator(.hidden)
      } else {
        ForEach(historyViewModel.records) { record in
          SessionRow(
            subtitle: record.trackerRangeText,
            durationText: record.duration.durationText
          )
          .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(action: { historyViewModel.deleteRecord(record) }) {
              Image(systemName: "trash")
            }
            .tint(AppColors.accent)
          }
          .listRowInsets(AppLayout.listRowInsets)
          .listRowBackground(Color.clear)
          .listRowSeparator(.hidden)
        }
      }
    }
    .listStyle(.plain)
    .listRowSpacing(AppLayout.vInset)
    .listSectionSpacing(0)
    .scrollIndicators(.hidden)
    .scrollContentBackground(.hidden)
    .foregroundStyle(AppColors.textPrimary)
    .onAppear {
      historyViewModel.reloadRecords()
    }
    .onChange(of: scenePhase) { _, phase in
      guard phase == .active else { return }
      historyViewModel.reloadRecords()
    }
  }

  private var summaryCard: some View {
    VStack(spacing: AppLayout.spacing * 4) {
      Text(String.trackerSummaryTotal)
        .font(AppFont.subtitle)
        .foregroundStyle(AppColors.textSecondary)
        .frame(maxWidth: .infinity, alignment: .center)

      Text(historyViewModel.totalDuration.durationText)
        .font(.system(size: 52, weight: .bold, design: .monospaced))
        .foregroundStyle(AppColors.accent)
        .lineLimit(1)
        .minimumScaleFactor(0.55)
        .frame(maxWidth: .infinity, alignment: .center)

      Text(historyViewModel.summaryText)
        .font(AppFont.subtitle)
        .foregroundStyle(AppColors.textSecondary)
        .multilineTextAlignment(.center)
        .lineLimit(2)
        .minimumScaleFactor(0.8)
        .frame(maxWidth: .infinity, alignment: .center)
    }
    .padding(.horizontal, AppLayout.cardPadding)
    .padding(.vertical, AppLayout.spacing * 8)
    .frame(maxWidth: .infinity)
    .card()
  }

}
