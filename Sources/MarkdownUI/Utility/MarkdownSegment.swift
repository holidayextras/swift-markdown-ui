import Foundation

/// Represents a parsed content block from Markdown text.
///
/// When carousel detection is enabled, the parser splits markdown into segments:
/// regular markdown content and image-only paragraphs (carousels).
public enum MarkdownSegment: Hashable, Sendable {
  /// A segment containing regular Markdown text.
  case markdown(String)

  /// A segment containing an image-only paragraph with extracted image items.
  case imageCarousel([MarkdownImageItem])
}
