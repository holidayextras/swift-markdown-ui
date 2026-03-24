import RegexBuilder

/// Regex patterns for detecting images in Markdown text.
///
/// Provides patterns for both standalone images (`![alt](src)`) and
/// linked images (`[![alt](src)](dest)`).
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public enum MarkdownImageRegex {
  /// Matches `[![alt](src)](dest)` — captures: alt, src, dest
  public static var linkedImage: Regex<(Substring, Substring, Substring, Substring)> {
    Regex {
      "[!["
      Capture { ZeroOrMore { CharacterClass.anyOf("]").inverted } }
      "]("
      Capture { OneOrMore { CharacterClass.anyOf(")").inverted } }
      ")]("
      Capture { OneOrMore { CharacterClass.anyOf(")").inverted } }
      ")"
    }
  }

  /// Matches `![alt](src)` — captures: alt, src
  public static var plainImage: Regex<(Substring, Substring, Substring)> {
    Regex {
      "!["
      Capture { ZeroOrMore { CharacterClass.anyOf("]").inverted } }
      "]("
      Capture { OneOrMore { CharacterClass.anyOf(")").inverted } }
      ")"
    }
  }
}
