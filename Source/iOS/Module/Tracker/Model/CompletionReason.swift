
import Foundation

/// Why a tracker session is being finalized. Drives whether the view model also stops
/// the underlying alarm and how the end timestamp is chosen.
enum CompletionReason {

  case manual
  case expired
  case externalStop

}
