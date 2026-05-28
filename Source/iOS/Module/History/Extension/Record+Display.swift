
import Foundation

extension Record {

  var trackerRangeText: String {
    let startTimeText = startedAt.formatted(date: .omitted, time: .shortened)
    let endTimeText = endedAt.formatted(date: .omitted, time: .shortened)
    let calendar = Calendar.current

    let startDateText = startedAt.formatted(date: .abbreviated, time: .omitted)

    if calendar.isDate(startedAt, inSameDayAs: endedAt) {
      return "\(startDateText), \(startTimeText)-\(endTimeText)"
    }

    let endDateText = endedAt.formatted(date: .abbreviated, time: .omitted)
    return "\(startDateText), \(startTimeText) - \(endDateText), \(endTimeText)"
  }

}
