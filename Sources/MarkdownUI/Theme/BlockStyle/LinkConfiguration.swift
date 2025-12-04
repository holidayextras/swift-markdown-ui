import SwiftUI

/// The properties of a Markdown link for custom styling.
///
/// When using ``Theme/customLink(_:)-6op3c``, you receive a `LinkConfiguration`
/// that provides access to the link's destination URL and text content,
/// allowing full control over how the link is rendered.
///
/// ```swift
/// let theme = Theme()
///   .customLink { configuration in
///     // Use styledText to create gradient text that remains clickable
///     configuration.styledText { index, count in
///       Color.gradientColor(from: [.blue, .purple], at: Double(index) / Double(max(count - 1, 1)))
///     }
///     + Text(Image(systemName: "arrow.up.right")).foregroundColor(.purple)
///   }
/// ```
public struct LinkConfiguration {
  /// The default rendered link text.
  ///
  /// This is the link text with the base link style applied.
  /// You can further customize it or replace it entirely.
  public let label: Text

  /// The link's destination URL.
  public let destination: URL

  /// The plain text content of the link.
  public let text: String

  /// Creates a styled, clickable link text with per-character coloring.
  ///
  /// Use this method to apply custom colors to each character while preserving
  /// the link's tap functionality.
  ///
  /// - Parameter colorProvider: A closure that receives the character index and total count,
  ///   and returns the color for that character.
  /// - Returns: A `Text` view with per-character coloring that remains clickable.
  ///
  /// Example:
  /// ```swift
  /// configuration.styledText { index, count in
  ///   let progress = Double(index) / Double(max(count - 1, 1))
  ///   return Color.gradientColor(from: [.orange, .red], at: progress)
  /// }
  /// ```
  public func styledText(colorProvider: (_ index: Int, _ count: Int) -> Color) -> Text {
    var attributedString = AttributedString(text)
    attributedString.link = destination

    let characters = Array(text)
    let count = characters.count

    var currentIndex = attributedString.startIndex
    for (index, _) in characters.enumerated() {
      guard currentIndex < attributedString.endIndex else { break }
      let nextIndex = attributedString.index(afterCharacter: currentIndex)
      let range = currentIndex..<nextIndex
      attributedString[range].foregroundColor = colorProvider(index, count)
      currentIndex = nextIndex
    }

    return Text(attributedString)
  }
}

