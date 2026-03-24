import SwiftUI

struct ParagraphView: View {
  @Environment(\.theme.paragraph) private var paragraph
  @Environment(\.theme.standaloneLink) private var standaloneLink

  private let content: [InlineNode]

  init(content: String) {
    self.init(
      content: [
        .text(content.hasSuffix("\n") ? String(content.dropLast()) : content)
      ]
    )
  }

  init(content: [InlineNode]) {
    self.content = content
  }

  var body: some View {
    let markdownContent = MarkdownContent(block: .paragraph(content: self.content))
    let paragraphLabel = self.paragraph.makeBody(
      configuration: .init(
        label: .init(self.label),
        content: markdownContent
      )
    )
    self.standaloneLink.makeBody(
      configuration: .init(
        standaloneLink: markdownContent.standaloneLink,
        label: .init(paragraphLabel)
      )
    )
  }

  @ViewBuilder private var label: some View {
    if let imageView = ImageView(content) {
      imageView
    } else if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *),
      let imageFlow = ImageFlow(content)
    {
      imageFlow
    } else {
      InlineText(content)
    }
  }
}
