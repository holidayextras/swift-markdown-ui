import Foundation

extension BlockNode {
  /// Returns the extracted images if this block is an image-only paragraph, or `nil` otherwise.
  ///
  /// A paragraph is image-only when it contains only images, links wrapping a single image,
  /// whitespace-only text, soft breaks, and line breaks.
  var carouselImages: [MarkdownImageItem]? {
    guard case .paragraph(let inlines) = self else { return nil }

    var images: [MarkdownImageItem] = []

    for inline in inlines {
      switch inline {
      case let .text(text) where text.trimmingCharacters(in: .whitespaces).isEmpty:
        continue
      case .softBreak, .lineBreak:
        continue
      case let .image(source, children):
        images.append(
          MarkdownImageItem(source: source, alt: children.renderPlainText())
        )
      case let .link(destination, children) where children.count == 1:
        if case let .image(source, altChildren) = children.first {
          images.append(
            MarkdownImageItem(
              source: source,
              alt: altChildren.renderPlainText(),
              destination: destination
            )
          )
        } else {
          return nil
        }
      default:
        return nil
      }
    }

    return images.isEmpty ? nil : images
  }
}
