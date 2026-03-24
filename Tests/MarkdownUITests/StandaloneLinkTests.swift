import MarkdownUI
import XCTest

final class StandaloneLinkTests: XCTestCase {
  func testStandaloneLink() {
    let content = MarkdownContent("[Title](https://example.com)")
    let link = content.standaloneLink
    XCTAssertNotNil(link)
    XCTAssertEqual(link?.title, "Title")
    XCTAssertEqual(link?.url, URL(string: "https://example.com"))
  }

  func testPlainText() {
    let content = MarkdownContent("Just some text")
    XCTAssertNil(content.standaloneLink)
  }

  func testLinkWithSurroundingText() {
    let content = MarkdownContent("Click [here](https://example.com) for details")
    XCTAssertNil(content.standaloneLink)
  }

  func testMultipleLinks() {
    let content = MarkdownContent("[Link 1](https://a.com) [Link 2](https://b.com)")
    XCTAssertNil(content.standaloneLink)
  }

  func testEmpty() {
    let content = MarkdownContent("")
    XCTAssertNil(content.standaloneLink)
  }

  func testComplexURL() {
    let content = MarkdownContent("[Search](https://example.com/path?q=hello&lang=en#section)")
    let link = content.standaloneLink
    XCTAssertNotNil(link)
    XCTAssertEqual(link?.title, "Search")
    XCTAssertEqual(link?.url, URL(string: "https://example.com/path?q=hello&lang=en#section"))
  }

  func testHeadingWithLinkIsNotStandalone() {
    let content = MarkdownContent("# [Title](https://example.com)")
    XCTAssertNil(content.standaloneLink)
  }

  func testMultipleBlocksNotStandalone() {
    let content = MarkdownContent("""
    [Link](https://example.com)

    Some other paragraph
    """)
    XCTAssertNil(content.standaloneLink)
  }
}
