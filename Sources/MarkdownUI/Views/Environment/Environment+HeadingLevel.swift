import SwiftUI

extension EnvironmentValues {
  /// The current heading level if rendering inside a heading, or `nil` otherwise.
  var headingLevel: Heading.Level? {
    get { self[HeadingLevelKey.self] }
    set { self[HeadingLevelKey.self] = newValue }
  }
}

private struct HeadingLevelKey: EnvironmentKey {
  static var defaultValue: Heading.Level? = nil
}

