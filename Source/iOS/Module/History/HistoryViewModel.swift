
import Foundation

/// Backs the history screen by exposing completed tracker sessions from `SessionStore`
/// together with derived aggregates the screen renders.
@MainActor
@Observable
final class HistoryViewModel {

  var records: [Record] = []

  @ObservationIgnored private let store: SessionStore

  init(store: SessionStore) {
    self.store = store
    reloadRecords()
  }

  func reloadRecords() {
    records = store.fetchCompletedSessions().compactMap(Record.init(session:))
  }

  func deleteRecord(_ record: Record) {
    store.deleteSession(id: record.id)
    reloadRecords()
  }

  var totalDuration: TimeInterval {
    records.reduce(0) { total, record in
      total + record.duration
    }
  }

  var fastCountText: String {
    records.count.formatted()
  }

  var dateRangeText: String {
    guard let firstStartedAt = records.map(\.startedAt).min(),
          let lastEndedAt = records.map(\.endedAt).max() else {
      return String.trackerSummaryNoDateRange
    }

    let firstDateText = firstStartedAt.formatted(date: .abbreviated, time: .omitted)
    let lastDateText = lastEndedAt.formatted(date: .abbreviated, time: .omitted)
    return firstDateText == lastDateText ? firstDateText : "\(firstDateText) - \(lastDateText)"
  }

  var summaryText: String {
    "\(fastCountText) \(String.trackerSummaryFastCount.lowercased()) • \(dateRangeText)"
  }

}
