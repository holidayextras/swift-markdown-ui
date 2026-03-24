import SwiftUI

/// A link that is the sole content of a paragraph.
public struct StandaloneLink: Sendable {
  /// The plain text content of the link.
  public let title: String

  /// The link's destination URL.
  public let url: URL
}

/// The properties of a paragraph that may contain a standalone link.
///
/// The theme ``Theme/standaloneLinkStyle`` block style receives a `StandaloneLinkConfiguration`
/// input in its `body` closure. When ``standaloneLink`` is non-nil, the paragraph contains
/// only a single link with no surrounding text.
public struct StandaloneLinkConfiguration {
  /// Non-nil when the paragraph contains only a single link.
  public let standaloneLink: StandaloneLink?

  /// A type-erased view of the default-rendered paragraph.
  public struct Label: View {
    init<L: View>(_ label: L) {
      self.body = AnyView(label)
    }

    public let body: AnyView
  }

  /// The default-rendered paragraph view.
  public let label: Label
}
