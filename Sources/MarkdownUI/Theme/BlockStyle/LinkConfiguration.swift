import SwiftUI

/// The properties of a Markdown link for custom styling.
///
/// When using ``Theme/customLink(_:)-swift.method``, you receive a `LinkConfiguration`
/// that provides access to the link's destination URL and text content,
/// allowing full control over how the link is rendered.
///
/// ```swift
/// let theme = Theme()
///   .customLink { configuration in
///     Text(configuration.title)
///       .foregroundColor(.blue)
///       .underline()
///   }
/// ```
public struct LinkConfiguration {
  /// The link's destination URL.
  public let destination: URL

  /// The plain text content of the link.
  public let title: String
}
