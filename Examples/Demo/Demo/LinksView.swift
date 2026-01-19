import MarkdownUI
import SwiftUI

struct LinksView: View {
  @State private var lastClickedLink: MarkdownLinkClickConfiguration?
  @State private var clickHistory: [(title: String, url: URL, isImage: Bool)] = []
  
  private let textLinksContent = """
    ## Text Links
    
    Click these links to see their titles:
    
    - [Visit GitHub](https://github.com)
    - [Read the CommonMark Spec](https://spec.co mmonmark.org/current/)
    - [Apple Developer Portal](https://developer.apple.com)
    """
  
  private let imageLinksContent = """
    ## Image Links

    Click each image to see its alt text as the title:

    [![First Image - Mountain](https://picsum.photos/200/150?1)](https://example.com/mountain)

    [![Second Image - Ocean](https://picsum.photos/200/150?2)](https://example.com/ocean)

    [![Third Image - Forest](https://picsum.photos/200/150?3)](https://example.com/forest)
    """
  
  private let mixedContent = """
    ## Mixed Content
    
    Here's a paragraph with both [text links](https://example.com/text) and images:
    
    [![Small image](https://picsum.photos/100/80)](https://example.com/image-link)
    
    And another [inline link](https://example.com/inline).
    """
  
  var body: some View {
    DemoView {
      // Info section
      Section("About This Demo") {
        Text("This demonstrates the new `openMarkdownLink` environment that provides access to the link's title/prompt at click time.")
          .font(.callout)
          .foregroundStyle(.secondary)
      }
      
      // Image Links - These use openMarkdownLink directly
      Section("Image Links (Direct Support)") {
        Markdown(imageLinksContent)
      }
      .environment(\.openMarkdownLink) { [self] configuration in
        print("Handler called: \(configuration.title)")
        clickHistory.insert((configuration.title, configuration.url, configuration.isImage), at: 0)
        lastClickedLink = configuration
        print("clickHistory count: \(clickHistory.count)")
        return .handled
      }
      
      // Text Links - These use the URL encoding approach
      Section("Text Links (URL Encoding)") {
        Markdown(textLinksContent)
      }
      .markdownCustomLink { configuration in
        var text = AttributedString(configuration.title)
        text.link = configuration.urlWithEncodedTitle
        text.foregroundColor = .blue
        text.underlineStyle = .single
        return Text(text)
      }
      .environment(\.openURL, OpenURLAction { url in
        if let title = url.markdownLinkTitle {
          let cleanURL = url.strippingMarkdownLinkTitle
          clickHistory.insert((title, cleanURL, false), at: 0)
          lastClickedLink = MarkdownLinkClickConfiguration(url: cleanURL, title: title, isImage: false)
        }
        return .handled
      })
      
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



