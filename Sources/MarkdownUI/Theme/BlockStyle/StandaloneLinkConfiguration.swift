import SwiftUI

/// A link that is the sole content of a paragraph.
public struct StandaloneLink: Sendable {
  /// The plain text content of the link.
  public let title: String

  /// The link's destination URL.
  public let url: URL
}

/// The properties of a paragraph containing a standalone link.
///
/// The theme ``Theme/standaloneLink`` block style receives a `StandaloneLinkConfiguration`
/// input in its `body` closure. This configuration is only used when the paragraph
/// contains exactly one link with no surrounding text.
public struct StandaloneLinkConfiguration {
  /// The standalone link detected in the paragraph.
  public let standaloneLink: StandaloneLink

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
