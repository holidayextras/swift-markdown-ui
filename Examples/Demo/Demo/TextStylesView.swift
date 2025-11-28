import MarkdownUI
import SwiftUI

struct TextStylesView: View {
  private let content = """
    ```
    **This is bold text**
    ```
    **This is bold text**
    ```
    *This text is italicized*
    ```
    *This text is italicized*
    ```
    ~~This was mistaken text~~
    ```
    ~~This was mistaken text~~
    ```
    **This text is _extremely_ important**
    ```
    **This text is _extremely_ important**
    ```
    ***All this text is important***
    ```
    ***All this text is important***
    ```
    MarkdownUI is fully compliant with the [CommonMark Spec](https://spec.commonmark.org/current/).
    ```
    MarkdownUI is fully compliant with the [CommonMark Spec](https://spec.commonmark.org/current/).
    ```
    Visit https://github.com.
    ```
    Visit https://github.com.
    ```
    Use `git status` to list all new or modified files that haven't yet been committed.
    ```
    Use `git status` to list all new or modified files that haven't yet been committed.
    """

  var body: some View {
    DemoView {
      Markdown(self.content)

      Section("Customization Example") {
        Markdown(self.content)
      }
      .markdownTextStyle(\.code) {
        FontFamilyVariant(.monospaced)
        BackgroundColor(.yellow.opacity(0.5))
      }
      .markdownTextStyle(\.emphasis) {
        FontStyle(.italic)
        UnderlineStyle(.single)
      }
      .markdownTextStyle(\.strong) {
        FontWeight(.heavy)
      }
      .markdownTextStyle(\.strikethrough) {
        StrikethroughStyle(.init(pattern: .solid, color: .red))
      }
      .markdownTextStyle(\.link) {
        ForegroundColor(.mint)
        UnderlineStyle(.init(pattern: .dot))
      }

        Section("Destination-Based Link Style") {
          Markdown("""
            Check out [GitHub](https://github.com) or run [this prompt](prompt:/ThisIsAPrompt).
            """)
        }
        .environment(\.openURL, OpenURLAction { url in
          if url.scheme == "prompt" {
            print("Prompt URL tapped: \(url)")
            return .handled
          }
          return .systemAction
        })
        .markdownTheme(
          Theme()
            .customLink { url in
              if url.scheme == "prompt" {
                ForegroundColor(.purple)
                UnderlineStyle(.init(pattern: .dot))
              } else {
                ForegroundColor(.blue)
                UnderlineStyle(.single)
              }
            }
        )
    }
  }
}

struct TextStylesView_Previews: PreviewProvider {
  static var previews: some View {
    TextStylesView()
  }
}
