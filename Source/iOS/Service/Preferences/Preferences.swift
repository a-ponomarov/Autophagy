
import Foundation

struct Preferences {

  private enum Constants {

    static let selectedDurationSecondsKey = "tracker.selectedDurationSeconds"

  }

  private let userDefaults: UserDefaults

  init(userDefaults: UserDefaults = .standard) {
    self.userDefaults = userDefaults
  }

  var selectedDurationSeconds: Int {
    get {
      let seconds = userDefaults.integer(forKey: Constants.selectedDurationSecondsKey)
      return seconds > 0 ? seconds : DurationDefaults.defaultDurationSeconds
    }
    nonmutating set {
      userDefaults.set(max(1, newValue), forKey: Constants.selectedDurationSecondsKey)
    }
  }

  func reset() {
    userDefaults.removeObject(forKey: Constants.selectedDurationSecondsKey)
  }

}
