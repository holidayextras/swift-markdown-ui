import XCTest

@testable import MarkdownUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
final class MarkdownSegmentParserTests: XCTestCase {
  func testReturnsSingleMarkdownSegmentForPlainText() {
    let result = MarkdownSegmentParser.parse("Hello, world!")

    XCTAssertEqual(result, [.markdown("Hello, world!")])
  }

  func testReturnsEmptyArrayForEmptyString() {
    let result = MarkdownSegmentParser.parse("")

    XCTAssertEqual(result, [])
  }

  func testJoinsMultipleTextParagraphsIntoSingleMarkdownSegment() {
    let input = "First paragraph\n\nSecond paragraph\n\nThird paragraph"
    let result = MarkdownSegmentParser.parse(input)

    XCTAssertEqual(result, [.markdown("First paragraph\n\nSecond paragraph\n\nThird paragraph")])
  }

  func testReturnsImageCarouselForSingleStandaloneImage() {
    let input = "![alt](https://example.com/image.png)"
    let result = MarkdownSegmentParser.parse(input)

    XCTAssertEqual(result, [
      .imageCarousel([
        MarkdownImageItem(source: "https://example.com/image.png", alt: "alt")
      ])
    ])
  }

  func testReturnsImageCarouselForMultipleStandaloneImages() {
    let input = "![first](https://example.com/1.png) ![second](https://example.com/2.png)"
    let result = MarkdownSegmentParser.parse(input)

    XCTAssertEqual(result, [
      .imageCarousel([
        MarkdownImageItem(source: "https://example.com/1.png", alt: "first"),
        MarkdownImageItem(source: "https://example.com/2.png", alt: "second"),
      ])
    ])
  }

  func testReturnsImageCarouselForLinkedImagesWithDestinations() {
    let input = "[![alt](https://example.com/image.png)](https://example.com)"
    let result = MarkdownSegmentParser.parse(input)

    XCTAssertEqual(result, [
      .imageCarousel([
        MarkdownImageItem(
          source: "https://example.com/image.png",
          alt: "alt",
          destination: "https://example.com"
        )
      ])
    ])
  }

  func testReturnsMarkdownBeforeCarouselWhenTextPrecedesImages() {
    let input = "Some text\n\n![image](https://example.com/image.png)"
    let result = MarkdownSegmentParser.parse(input)

    XCTAssertEqual(result, [
      .markdown("Some text"),
      .imageCarousel([
        MarkdownImageItem(source: "https://example.com/image.png", alt: "image")
      ]),
    ])
  }

  func testReturnsCarouselThenMarkdownWhenImagesPrecedeText() {
    let input = "![image](https://example.com/image.png)\n\nSome text"
    let result = MarkdownSegmentParser.parse(input)

    XCTAssertEqual(result, [
      .imageCarousel([
        MarkdownImageItem(source: "https://example.com/image.png", alt: "image")
      ]),
      .markdown("Some text"),
    ])
  }

  func testReturnsMarkdownWhenParagraphHasImagesMixedWithText() {
    let input = "Check out this ![image](https://example.com/image.png) in the text"
    let result = MarkdownSegmentParser.parse(input)

    XCTAssertEqual(result, [
      .markdown("Check out this ![image](https://example.com/image.png) in the text")
    ])
  }

  func testHandlesTextBetweenTwoImageOnlyParagraphs() {
    let input = """
      ![first](https://example.com/1.png)

      Some text in between

      ![second](https://example.com/2.png)
      """
    let result = MarkdownSegmentParser.parse(input)

    XCTAssertEqual(result, [
      .imageCarousel([
        MarkdownImageItem(source: "https://example.com/1.png", alt: "first")
      ]),
      .markdown("Some text in between"),
      .imageCarousel([
        MarkdownImageItem(source: "https://example.com/2.png", alt: "second")
      ]),
    ])
  }

  func testPreservesDocumentOrderForMixedLinkedAndStandaloneImages() {
    let input = "![a](https://example.com/1.png) [![b](https://example.com/2.png)](https://example.com/link) ![c](https://example.com/3.png)"
    let result = MarkdownSegmentParser.parse(input)

    XCTAssertEqual(result, [
      .imageCarousel([
        MarkdownImageItem(source: "https://example.com/1.png", alt: "a"),
        MarkdownImageItem(source: "https://example.com/2.png", alt: "b", destination: "https://example.com/link"),
        MarkdownImageItem(source: "https://example.com/3.png", alt: "c"),
      ])
    ])
  }

  func testHandlesImagesWithQueryParametersInURLs() {
    let input = "![photo](https://example.com/image.png?width=100&height=200)"
    let result = MarkdownSegmentParser.parse(input)

    XCTAssertEqual(result, [
      .imageCarousel([
        MarkdownImageItem(
          source: "https://example.com/image.png?width=100&height=200",
          alt: "photo"
        )
      ])
    ])
  }
}
