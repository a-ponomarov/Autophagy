
import AlarmKit
import Foundation

struct TrackerActivityMetadata: AlarmMetadata, Codable, Hashable, Sendable {

  let duration: TimeInterval

}
