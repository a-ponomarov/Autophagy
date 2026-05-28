
import Foundation

struct Record: Identifiable {

  let id: UUID
  let startedAt: Date
  let endedAt: Date

  init(
    id: UUID = UUID(),
    startedAt: Date,
    endedAt: Date
  ) {
    self.id = id
    self.startedAt = startedAt
    self.endedAt = endedAt
  }

  init?(session: SessionModel) {
    guard let endedAt = session.endedAt else { return nil }

    self.id = session.id
    self.startedAt = session.startedAt
    self.endedAt = endedAt
  }

  var duration: TimeInterval {
    endedAt.timeIntervalSince(startedAt)
  }

}
