import SwiftUI

extension EnvironmentValues {
  /// The current heading level (1-6) if rendering inside a heading, or `nil` otherwise.
  var headingLevel: Int? {
    get { self[HeadingLevelKey.self] }
    set { self[HeadingLevelKey.self] = newValue }
  }
}

private struct HeadingLevelKey: EnvironmentKey {
  static var defaultValue: Int? = nil
}

