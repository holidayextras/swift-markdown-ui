import SwiftUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct MarkdownSegmentedView: View {
  @Environment(\.theme) private var theme
  @Environment(\.colorScheme) private var colorScheme

  private let segments: [MarkdownSegment]

  init(segments: [MarkdownSegment]) {
    self.segments = segments
  }

  var body: some View {
    VStack(spacing: 0) {
      ForEach(self.segments, id: \.self) { segment in
        switch segment {
        case .markdown(let markdownString):
          self.markdownView(for: markdownString)
        case .imageCarousel(let images):
          self.carouselView(for: images)
        }
      }
    }
  }

  @ViewBuilder
  private func carouselView(for images: [MarkdownImageItem]) -> some View {
    if images.count >= self.theme.carouselThreshold,
      let carousel = self.theme.carousel
    {
      carousel.makeBody(configuration: CarouselConfiguration(images: images))
    } else {
      self.markdownView(for: images.map(\.markdownRepresentation).joined(separator: " "))
    }
  }

  private func markdownView(for markdownString: String) -> some View {
    let content = MarkdownContent(markdownString)
    let blocks = content.blocks.filterImagesMatching(colorScheme: self.colorScheme)
    return BlockSequence(blocks)
  }
}
