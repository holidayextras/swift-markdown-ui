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
///     configuration.label
///       + Text(" ")
///       + Text(Image(systemName: "arrow.up.right")).foregroundColor(.purple)
///   }
/// ```
public struct LinkConfiguration {
  /// The default rendered link text with the base link style applied.
  public let label: Text

  /// The link's destination URL.
  public let destination: URL

  /// The plain text content of the link.
  public let title: String
}
