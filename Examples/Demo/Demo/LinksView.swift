import MarkdownUI
import SwiftUI

struct LinksView: View {
  @State private var lastClickedLink: MarkdownLinkClickConfiguration?
  @State private var clickHistory: [(title: String, url: URL, isImage: Bool)] = []

  private let mixedContent = """
    ## All Links Demo

    Both text links and image links now use the same `openMarkdownLink` handler!

    ### Text Links

    - [Visit GitHub](https://github.com)
    - [Read the CommonMark Spec](https://spec.commonmark.org/current/)
    - [Apple Developer Portal](https://developer.apple.com)

    ### Image Links

    [![First Image - Mountain](https://picsum.photos/200/150?1)](https://example.com/mountain)

    [![Second Image - Ocean](https://picsum.photos/200/150?2)](https://example.com/ocean)

    ### Mixed Paragraph

    Here's a paragraph with a [text link](https://example.com/text) and an image:

    [![Inline image](https://picsum.photos/100/80)](https://example.com/image-link)

    And another [inline link](https://example.com/inline) at the end.
    """

  var body: some View {
    DemoView {
      // Info section
      Section("About This Demo") {
        Text("This demonstrates the `openMarkdownLink` environment that provides access to the link's title at click time for ALL links (both text and image).")
          .font(.callout)
          .foregroundStyle(.secondary)
      }

      // All links use the same handler
      Section("Links") {
        Markdown(mixedContent)
      }
      .environment(\.openMarkdownLink) { configuration in
        clickHistory.insert((configuration.title, configuration.url, configuration.isImage), at: 0)
        lastClickedLink = configuration
        return .handled
      }

      // Click history
      Section("Click History") {
        if clickHistory.isEmpty {
          Text("Click a link above to see it here...")
            .font(.callout)
            .foregroundStyle(.secondary)
            .italic()
        } else {
          ForEach(Array(clickHistory.prefix(5).enumerated()), id: \.offset) { _, click in
            VStack(alignment: .leading, spacing: 4) {
              HStack {
                Image(systemName: click.isImage ? "photo" : "link")
                  .foregroundStyle(click.isImage ? .orange : .blue)
                Text(click.title)
                  .fontWeight(.medium)
              }
              Text(click.url.absoluteString)
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
          }
        }
      }

      // Last clicked details
      if let config = lastClickedLink {
        Section("Last Clicked Details") {
          LabeledContent("Title (Prompt)") {
            Text(config.title)
              .fontWeight(.semibold)
              .foregroundStyle(.primary)
          }
          LabeledContent("URL") {
            Text(config.url.absoluteString)
              .font(.caption)
          }
          LabeledContent("Is Image Link") {
            Text(config.isImage ? "Yes" : "No")
          }
        }
        .listRowBackground(Color.green.opacity(0.1))
      }
    }
  }
}

struct LinksView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      LinksView()
        .navigationTitle("Links")
        .navigationBarTitleDisplayMode(.inline)
    }
  }
}
