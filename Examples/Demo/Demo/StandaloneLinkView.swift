import MarkdownUI
import SwiftUI

struct StandaloneLinkView: View {
  @Environment(\.openURL) private var openURL
  @State private var lastTappedLink: StandaloneLink?

  private let markdownContent = """
    ## Standalone Link Demo

    This paragraph has a [regular link](https://example.com/inline) mixed with text.

    [Visit GitHub](https://github.com)

    Just some plain text paragraph here.

    [Apple Developer](https://developer.apple.com)

    Another paragraph with **bold** and *italic* text.

    [Search Example](https://example.com/search?q=hello&lang=en)
    """

  var body: some View {
    DemoView(themeOptions: []) {
      Section("About") {
        Text("Demonstrates the `.standaloneLink` theme modifier. Paragraphs containing only a single link render as pill buttons. All other paragraphs render normally.")
          .font(.callout)
          .foregroundStyle(.secondary)
      }

      Section("Markdown") {
        Markdown(markdownContent)
          .markdownTheme(
            Theme()
              .standaloneLink { configuration in
                Button {
                  lastTappedLink = configuration.standaloneLink
                  openURL(configuration.standaloneLink.url)
                } label: {
                  Text(configuration.standaloneLink.title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                      Capsule()
                        .fill(.blue.gradient)
                    )
                    .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
              }
          )
      }
    }
  }
}

struct StandaloneLinkView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      StandaloneLinkView()
        .navigationTitle("Standalone Links")
        .navigationBarTitleDisplayMode(.inline)
    }
  }
}
