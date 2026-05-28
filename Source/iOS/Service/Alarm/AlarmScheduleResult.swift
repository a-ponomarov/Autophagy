
import Foundation

/// Outcome of scheduling a tracker alarm. The view model uses this to decide whether to
/// continue the start flow, surface a permission prompt, or stop silently.
enum AlarmScheduleResult {

  case scheduled
  case authorizationDenied
  case failed

}
