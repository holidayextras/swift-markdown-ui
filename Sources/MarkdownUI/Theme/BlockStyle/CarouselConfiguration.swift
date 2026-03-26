import SwiftUI

/// The properties of a Markdown image carousel.
///
/// The theme ``Theme/carousel`` block style receives a `CarouselConfiguration`
/// input in its `body` closure.
public struct CarouselConfiguration {
  /// The images extracted from the image-only paragraph.
  public let images: [MarkdownImageItem]
}
