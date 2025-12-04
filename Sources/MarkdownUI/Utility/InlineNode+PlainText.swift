import Foundation

extension Sequence where Element == InlineNode {
  func renderPlainText() -> String {
    self.collect { inline in
      switch inline {
      case .text(let content):
        return [content]
      case .softBreak:
        return [" "]
      case .lineBreak:
        return ["\n"]
      case .code(let content):
        return [content]
      case .html(let content):
        return [content]
      default:
        return []
      }
    }
    .joined()
  }

  /// Calculates the total character count for text gradient purposes.
  /// - Parameter softBreakMode: The soft break mode to use for calculating text length.
  /// - Returns: The total character count of plain text in this inline sequence.
  func plainTextLength(softBreakMode: SoftBreak.Mode) -> Int {
    self.collect { inline in
      switch inline {
      case .text(let content):
        return [content.count]
      case .softBreak:
        switch softBreakMode {
        case .space:
          return [1]
        case .lineBreak:
          return [1]
        }
      case .lineBreak:
        return [1]
      case .code(let content):
        return [content.count]
      case .html(let content):
        // Only count <br> as a single character, skip other HTML
        let tag = HTMLTag(content)
        if tag?.name.lowercased() == "br" {
          return [1]
        }
        return [content.count]
      default:
        return []
      }
    }
    .reduce(0, +)
  }
}
