import Foundation

/// A data model representing a parsed image from Markdown content.
///
/// `MarkdownImageItem` captures the source URL, alt text, and optional link destination
/// for both standalone images (`![alt](src)`) and linked images (`[![alt](src)](dest)`).
public struct MarkdownImageItem: Hashable, Sendable {
  /// The image URL (the `src` in `![alt](src)`).
  public let source: String

  /// The alt text of the image.
  public let alt: String

  /// The optional link URL when the image is wrapped in a link (`[![alt](src)](dest)`).
  public let destination: String?

  public init(source: String, alt: String, destination: String? = nil) {
    self.source = source
    self.alt = alt
    self.destination = destination
  }

  /// Reconstructs the Markdown representation of this image.
  var markdownRepresentation: String {
    if let destination {
      return "[![\(alt)](\(source))](\(destination))"
    } else {
      return "![\(alt)](\(source))"
    }
  }
}
