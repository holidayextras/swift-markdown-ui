import Foundation

/// Splits markdown text into segments, detecting image-only paragraphs.
///
/// A paragraph is considered "image-only" when it contains only image references
/// (both standalone and linked) and whitespace. Image-only paragraphs are emitted
/// as `.imageCarousel` segments; all other content is grouped into `.markdown` segments.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public enum MarkdownSegmentParser {
  /// Parses a markdown string into an array of segments.
  ///
  /// - Parameter markdown: The raw markdown text to parse.
  /// - Returns: An array of ``MarkdownSegment`` values.
  public static func parse(_ markdown: String) -> [MarkdownSegment] {
    var segments: [MarkdownSegment] = []
    var markdownAccumulator: [String] = []

    let paragraphs = markdown
      .components(separatedBy: "\n\n")
      .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }

    for paragraph in paragraphs {
      let images = extractImages(from: paragraph)

      if !images.isEmpty, isImageOnlyParagraph(paragraph) {
        if !markdownAccumulator.isEmpty {
          segments.append(.markdown(markdownAccumulator.joined(separator: "\n\n")))
          markdownAccumulator = []
        }
        segments.append(.imageCarousel(images))
      } else {
        markdownAccumulator.append(paragraph)
      }
    }

    if !markdownAccumulator.isEmpty {
      segments.append(.markdown(markdownAccumulator.joined(separator: "\n\n")))
    }

    return segments
  }

  private static func isImageOnlyParagraph(_ paragraph: String) -> Bool {
    paragraph
      .replacing(MarkdownImageRegex.linkedImage, with: "")
      .replacing(MarkdownImageRegex.plainImage, with: "")
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .isEmpty
  }

  private static func extractImages(from paragraph: String) -> [MarkdownImageItem] {
    let linkedMatches = paragraph.matches(of: MarkdownImageRegex.linkedImage)
    let linkedRanges = linkedMatches.map(\.range)

    let linkedItems: [(String.Index, MarkdownImageItem)] = linkedMatches.map { match in
      (
        match.range.lowerBound,
        MarkdownImageItem(
          source: String(match.output.2),
          alt: String(match.output.1),
          destination: String(match.output.3)
        )
      )
    }

    let standaloneItems: [(String.Index, MarkdownImageItem)] = paragraph
      .matches(of: MarkdownImageRegex.plainImage)
      .compactMap { match in
        let overlapsLinked = linkedRanges.contains { $0.overlaps(match.range) }
        guard !overlapsLinked else { return nil }

        return (
          match.range.lowerBound,
          MarkdownImageItem(
            source: String(match.output.2),
            alt: String(match.output.1),
            destination: nil
          )
        )
      }

    return (linkedItems + standaloneItems)
      .sorted { $0.0 < $1.0 }
      .map(\.1)
  }
}
