import SwiftUI

/// Configuration passed to a custom markdown link action handler.
///
/// This provides all the information about a link when it's clicked,
/// allowing you to access both the destination URL and the link's text content.
public struct MarkdownLinkClickConfiguration {
  /// The link's destination URL.
  public let url: URL
  
  /// The plain text content of the link (the link title/prompt).
  ///
  /// For text links like `[Visit our site](https://example.com)`, this would be "Visit our site".
  /// For image links like `[![Alt text](image.jpg)](https://example.com)`, this would be the alt text.
  public let title: String
  
  /// Whether this link wraps an image.
  public let isImage: Bool
  
  public init(url: URL, title: String, isImage: Bool = false) {
    self.url = url
    self.title = title
    self.isImage = isImage
  }
}

/// The result of handling a markdown link action.
public enum MarkdownLinkActionResult {
  /// The action was handled by the handler.
  case handled
  /// The action should be handled by the system (falls back to openURL).
  case systemAction
  /// The action was discarded.
  case discarded
}

extension EnvironmentValues {
  /// A custom action to perform when a markdown link is clicked.
  ///
  /// When set, this action is called instead of `openURL`, providing access to both
  /// the destination URL and the link's text content (title/prompt).
  ///
  /// ```swift
  /// Markdown {
  ///   """
  ///   Check out [our documentation](https://example.com/docs)!
  ///   """
  /// }
  /// .environment(\.openMarkdownLink) { configuration in
  ///   print("Link clicked: \(configuration.title) -> \(configuration.url)")
  ///   return .handled
  /// }
  /// ```
  public var openMarkdownLink: ((MarkdownLinkClickConfiguration) -> MarkdownLinkActionResult)? {
    get { self[OpenMarkdownLinkKey.self] }
    set { self[OpenMarkdownLinkKey.self] = newValue }
  }
}

private struct OpenMarkdownLinkKey: EnvironmentKey {
  static var defaultValue: ((MarkdownLinkClickConfiguration) -> MarkdownLinkActionResult)? = nil
}

// MARK: - Text Link Helpers

/// A special query parameter key used to encode link titles in URLs.
/// This enables text links (which use SwiftUI's built-in openURL) to pass their title through the URL.
private let markdownLinkTitleKey = "_mdLinkTitle"

extension URL {
  /// Creates a URL with the link title encoded as a query parameter.
  ///
  /// This is useful for text links where SwiftUI's `openURL` action only receives the URL.
  /// By encoding the title in the URL, you can extract it in your `openURL` handler.
  ///
  /// - Parameters:
  ///   - url: The original destination URL.
  ///   - title: The link's text content to encode.
  /// - Returns: A new URL with the title encoded, or the original URL if encoding fails.
  public static func markdownLink(_ url: URL, title: String) -> URL {
    guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
      return url
    }
    
    var queryItems = components.queryItems ?? []
    queryItems.append(URLQueryItem(name: markdownLinkTitleKey, value: title))
    components.queryItems = queryItems
    
    return components.url ?? url
  }
  
  /// Extracts the link title from a URL that was encoded using `markdownLink(_:title:)`.
  ///
  /// - Returns: The decoded title if present, or `nil` if the URL doesn't contain an encoded title.
  public var markdownLinkTitle: String? {
    guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
      return nil
    }
    return components.queryItems?.first(where: { $0.name == markdownLinkTitleKey })?.value
  }
  
  /// Returns the original URL without the encoded link title query parameter.
  ///
  /// Use this to get the clean destination URL after extracting the title.
  public var strippingMarkdownLinkTitle: URL {
    guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
      return self
    }
    
    components.queryItems = components.queryItems?.filter { $0.name != markdownLinkTitleKey }
    
    // If no query items remain, remove the query string entirely
    if components.queryItems?.isEmpty == true {
      components.queryItems = nil
    }
    
    return components.url ?? self
  }
}

extension LinkConfiguration {
  /// Creates a URL with this link's title encoded as a query parameter.
  ///
  /// Use this in your `customLink` closure to create URLs that preserve the title
  /// for extraction in your `openURL` handler.
  ///
  /// ```swift
  /// .markdownCustomLink { configuration in
  ///   var attributedString = AttributedString(configuration.title)
  ///   attributedString.link = configuration.urlWithEncodedTitle
  ///   return Text(attributedString)
  /// }
  ///
  /// .environment(\.openURL, OpenURLAction { url in
  ///   if let title = url.markdownLinkTitle {
  ///     let cleanURL = url.strippingMarkdownLinkTitle
  ///     // Now you have both `title` and `cleanURL`
  ///   }
  ///   return .handled
  /// })
  /// ```
  public var urlWithEncodedTitle: URL {
    URL.markdownLink(destination, title: title)
  }
}

