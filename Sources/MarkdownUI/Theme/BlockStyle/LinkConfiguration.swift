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
///
/// If the link is inside a heading, you can access the heading level:
///
/// ```swift
/// .customLink { configuration in
///   if let level = configuration.headingLevel {
///     // This link is inside a heading - style accordingly
///   }
/// }
/// ```
public struct LinkConfiguration {
  /// The link's destination URL.
  public let destination: URL

  /// The plain text content of the link.
  public let title: String

  /// The heading level (1-6) if this link is inside a heading, or `nil` otherwise.
  public let headingLevel: Int?
}
