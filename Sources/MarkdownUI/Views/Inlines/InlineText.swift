import SwiftUI

struct InlineText: View {
  @Environment(\.inlineImageProvider) private var inlineImageProvider
  @Environment(\.baseURL) private var baseURL
  @Environment(\.imageBaseURL) private var imageBaseURL
  @Environment(\.softBreakMode) private var softBreakMode
  @Environment(\.headingLevel) private var headingLevel
  @Environment(\.theme) private var theme
  @Environment(\.openMarkdownLink) private var openMarkdownLink
  @Environment(\.openURL) private var openURL

  @State private var inlineImages: [String: Image] = [:]

  private let inlines: [InlineNode]

  init(_ inlines: [InlineNode]) {
    self.inlines = inlines
  }

  var body: some View {
    TextStyleAttributesReader { attributes in
      self.inlines.renderText(
        baseURL: self.baseURL,
        textStyles: .init(
          code: self.theme.code,
          emphasis: self.theme.emphasis,
          strong: self.theme.strong,
          strikethrough: self.theme.strikethrough,
          link: self.theme.link,
          customLink: self.theme.customLink
        ),
        images: self.inlineImages,
        softBreakMode: self.softBreakMode,
        headingLevel: self.headingLevel,
        attributes: attributes
      )
    }
    .environment(\.openURL, OpenURLAction { url in
      self.handleLinkTap(url: url)
    })
    .task(id: self.inlines) {
      self.inlineImages = (try? await self.loadInlineImages()) ?? [:]
    }
  }

  private func handleLinkTap(url: URL) -> OpenURLAction.Result {
    // Extract the encoded title from the URL
    let title = url.markdownLinkTitle ?? ""
    let cleanURL = url.strippingMarkdownLinkTitle

    if let openMarkdownLink {
      let configuration = MarkdownLinkClickConfiguration(url: cleanURL, title: title, isImage: false)
      let result = openMarkdownLink(configuration)

      switch result {
      case .handled, .discarded:
        return .handled
      case .systemAction:
        return .systemAction
      }
    } else {
      // No custom handler, use system action with clean URL
      openURL(cleanURL)
      return .handled
    }
  }

  private func loadInlineImages() async throws -> [String: Image] {
    let images = Set(self.inlines.compactMap(\.imageData))
    guard !images.isEmpty else { return [:] }

    return try await withThrowingTaskGroup(of: (String, Image).self) { taskGroup in
      for image in images {
        guard let url = URL(string: image.source, relativeTo: self.imageBaseURL) else {
          continue
        }

        taskGroup.addTask {
          (image.source, try await self.inlineImageProvider.image(with: url, label: image.alt))
        }
      }

      var inlineImages: [String: Image] = [:]

      for try await result in taskGroup {
        inlineImages[result.0] = result.1
      }

      return inlineImages
    }
  }
}
