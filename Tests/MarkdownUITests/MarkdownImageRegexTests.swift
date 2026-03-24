import XCTest

@testable import MarkdownUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
final class MarkdownImageRegexTests: XCTestCase {
  // MARK: - plainImage tests

  func testPlainImageMatchesStandaloneImage() {
    let input = "![alt text](https://example.com/image.png)"
    let matches = input.matches(of: MarkdownImageRegex.plainImage)

    XCTAssertEqual(matches.count, 1)
    XCTAssertEqual(String(matches[0].output.1), "alt text")
    XCTAssertEqual(String(matches[0].output.2), "https://example.com/image.png")
  }

  func testPlainImageMatchesImageWithEmptyAlt() {
    let input = "![](https://example.com/image.png)"
    let matches = input.matches(of: MarkdownImageRegex.plainImage)

    XCTAssertEqual(matches.count, 1)
    XCTAssertEqual(String(matches[0].output.1), "")
    XCTAssertEqual(String(matches[0].output.2), "https://example.com/image.png")
  }

  func testPlainImageMatchesImageWithQueryParameters() {
    let input = "![photo](https://example.com/image.png?width=100&height=200)"
    let matches = input.matches(of: MarkdownImageRegex.plainImage)

    XCTAssertEqual(matches.count, 1)
    XCTAssertEqual(String(matches[0].output.1), "photo")
    XCTAssertEqual(String(matches[0].output.2), "https://example.com/image.png?width=100&height=200")
  }

  func testPlainImageDoesNotMatchRegularLink() {
    let input = "[text](https://example.com)"
    let matches = input.matches(of: MarkdownImageRegex.plainImage)

    XCTAssertEqual(matches.count, 0)
  }

  func testPlainImageFindsAllImagesInMultiImageParagraph() {
    let input = "![first](https://example.com/1.png) ![second](https://example.com/2.png)"
    let matches = input.matches(of: MarkdownImageRegex.plainImage)

    XCTAssertEqual(matches.count, 2)
    XCTAssertEqual(String(matches[0].output.1), "first")
    XCTAssertEqual(String(matches[1].output.1), "second")
  }

  // MARK: - linkedImage tests

  func testLinkedImageMatchesFullPattern() {
    let input = "[![alt text](https://example.com/image.png)](https://example.com)"
    let matches = input.matches(of: MarkdownImageRegex.linkedImage)

    XCTAssertEqual(matches.count, 1)
    XCTAssertEqual(String(matches[0].output.1), "alt text")
    XCTAssertEqual(String(matches[0].output.2), "https://example.com/image.png")
    XCTAssertEqual(String(matches[0].output.3), "https://example.com")
  }

  func testLinkedImageMatchesWithComplexQueryParameters() {
    let input = "[![photo](https://cdn.example.com/img.jpg?w=400&q=80)](https://example.com/gallery?id=123&page=1)"
    let matches = input.matches(of: MarkdownImageRegex.linkedImage)

    XCTAssertEqual(matches.count, 1)
    XCTAssertEqual(String(matches[0].output.1), "photo")
    XCTAssertEqual(String(matches[0].output.2), "https://cdn.example.com/img.jpg?w=400&q=80")
    XCTAssertEqual(String(matches[0].output.3), "https://example.com/gallery?id=123&page=1")
  }

  func testLinkedImageDoesNotMatchStandaloneImage() {
    let input = "![alt](https://example.com/image.png)"
    let matches = input.matches(of: MarkdownImageRegex.linkedImage)

    XCTAssertEqual(matches.count, 0)
  }

  func testLinkedImageMatchesWithEmptyAlt() {
    let input = "[![](https://example.com/image.png)](https://example.com)"
    let matches = input.matches(of: MarkdownImageRegex.linkedImage)

    XCTAssertEqual(matches.count, 1)
    XCTAssertEqual(String(matches[0].output.1), "")
    XCTAssertEqual(String(matches[0].output.2), "https://example.com/image.png")
    XCTAssertEqual(String(matches[0].output.3), "https://example.com")
  }
}
