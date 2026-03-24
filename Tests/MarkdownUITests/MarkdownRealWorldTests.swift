import XCTest

@testable import MarkdownUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
final class MarkdownRealWorldTests: XCTestCase {
  private let hotelCarousel = """
    ![Novotel](https://holidayextras.imgix.net/libraryimages/4143-birmingham-airport-novotel-hotel-mobile.png?mark-align=top%2C%20center&mark64=aHR0cHM6Ly9kbXkwYjlvZXByejBmLmNsb3VkZnJvbnQubmV0L3RyaXAtZXhwZXJpZW5jZS9wcmljZS1waWxsLTI0LnBuZw&txt-align=top%2C%20center&txt-size=18&txt-color=fff&txt-font=bold&w=104&txt=%C2%A3220.00&txt-y=10)
    ![Ibis](https://holidayextras.imgix.net/libraryimages/4143-birmingham-airport-ibis-hotel-mobile.png?mark-align=top%2C%20center&mark64=aHR0cHM6Ly9kbXkwYjlvZXByejBmLmNsb3VkZnJvbnQubmV0L3RyaXAtZXhwZXJpZW5jZS9wcmljZS1waWxsLTI0LnBuZw&txt-align=top%2C%20center&txt-size=18&txt-color=fff&txt-font=bold&w=104&txt=%C2%A3162.00&txt-y=10)
    ![Hilton Garden Inn](https://holidayextras.imgix.net/libraryimages/4143-birmingham-airport-hilton-garden-inn-hotel-mobile-2.png?mark-align=top%2C%20center&mark64=aHR0cHM6Ly9kbXkwYjlvZXByejBmLmNsb3VkZnJvbnQubmV0L3RyaXAtZXhwZXJpZW5jZS9wcmljZS1waWxsLTI0LnBuZw&txt-align=top%2C%20center&txt-size=18&txt-color=fff&txt-font=bold&w=104&txt=%C2%A3186.00&txt-y=10)
    ![Hilton Metropole](https://holidayextras.imgix.net/libraryimages/4143-birmingham-airport-hilton-metropole-hotelmobile.png?mark-align=top%2C%20center&mark64=aHR0cHM6Ly9kbXkwYjlvZXByejBmLmNsb3VkZnJvbnQubmV0L3RyaXAtZXhwZXJpZW5jZS9wcmljZS1waWxsLTI0LnBuZw&txt-align=top%2C%20center&txt-size=18&txt-color=fff&txt-font=bold&w=104&txt=%C2%A3186.00&txt-y=10)
    """

  func testRegexMatchesImgixURLsWithComplexQueryParams() {
    let matches = hotelCarousel.matches(of: MarkdownImageRegex.plainImage)

    XCTAssertEqual(matches.count, 4)
    XCTAssertEqual(String(matches[0].output.1), "Novotel")
    XCTAssertEqual(String(matches[1].output.1), "Ibis")
    XCTAssertEqual(String(matches[2].output.1), "Hilton Garden Inn")
    XCTAssertEqual(String(matches[3].output.1), "Hilton Metropole")

    // Verify full URL with query params is captured
    XCTAssertTrue(String(matches[0].output.2).contains("txt=%C2%A3220.00"))
    XCTAssertTrue(String(matches[1].output.2).contains("txt=%C2%A3162.00"))
  }

  func testParserDetectsHotelCarouselAsImageOnly() {
    let segments = MarkdownSegmentParser.parse(hotelCarousel)

    XCTAssertEqual(segments.count, 1)
    if case .imageCarousel(let images) = segments.first {
      XCTAssertEqual(images.count, 4)
      XCTAssertEqual(images[0].alt, "Novotel")
      XCTAssertEqual(images[1].alt, "Ibis")
      XCTAssertEqual(images[2].alt, "Hilton Garden Inn")
      XCTAssertEqual(images[3].alt, "Hilton Metropole")
      XCTAssertNil(images[0].destination)
      XCTAssertNil(images[3].destination)
    } else {
      XCTFail("Expected a single imageCarousel segment")
    }
  }

  func testParserHandlesStoryWithTwoCarousels() {
    let story = """
      # Hotels at Birmingham Airport

      Choose from our selection of hotels:

      ![Novotel](https://holidayextras.imgix.net/libraryimages/4143-birmingham-airport-novotel-hotel-mobile.png?w=104&txt=%C2%A3220.00)
      ![Ibis](https://holidayextras.imgix.net/libraryimages/4143-birmingham-airport-ibis-hotel-mobile.png?w=104&txt=%C2%A3162.00)
      ![Hilton Garden Inn](https://holidayextras.imgix.net/libraryimages/4143-birmingham-airport-hilton-garden-inn-hotel-mobile-2.png?w=104&txt=%C2%A3186.00)
      ![Hilton Metropole](https://holidayextras.imgix.net/libraryimages/4143-birmingham-airport-hilton-metropole-hotelmobile.png?w=104&txt=%C2%A3186.00)

      Or view our premium options:

      ![Novotel](https://holidayextras.imgix.net/libraryimages/4143-birmingham-airport-novotel-hotel-mobile.png?w=104&txt=%C2%A3220.00)
      ![Ibis](https://holidayextras.imgix.net/libraryimages/4143-birmingham-airport-ibis-hotel-mobile.png?w=104&txt=%C2%A3162.00)
      ![Hilton Garden Inn](https://holidayextras.imgix.net/libraryimages/4143-birmingham-airport-hilton-garden-inn-hotel-mobile-2.png?w=104&txt=%C2%A3186.00)
      ![Hilton Metropole](https://holidayextras.imgix.net/libraryimages/4143-birmingham-airport-hilton-metropole-hotelmobile.png?w=104&txt=%C2%A3186.00)

      Book now for the best rates!
      """
    let segments = MarkdownSegmentParser.parse(story)

    XCTAssertEqual(segments.count, 5)
    if case .markdown = segments[0] {} else { XCTFail("Expected markdown at [0]") }
    if case .imageCarousel(let imgs1) = segments[1] { XCTAssertEqual(imgs1.count, 4) }
    else { XCTFail("Expected carousel at [1]") }
    if case .markdown = segments[2] {} else { XCTFail("Expected markdown at [2]") }
    if case .imageCarousel(let imgs2) = segments[3] { XCTAssertEqual(imgs2.count, 4) }
    else { XCTFail("Expected carousel at [3]") }
    if case .markdown = segments[4] {} else { XCTFail("Expected markdown at [4]") }
  }

  func testLinkedHotelImagesDetectedAsCarousel() {
    let input = """
      [![Novotel](https://holidayextras.imgix.net/img/novotel.png?w=104&txt=%C2%A3220.00)](https://example.com/novotel) [![Ibis](https://holidayextras.imgix.net/img/ibis.png?w=104&txt=%C2%A3162.00)](https://example.com/ibis) [![Hilton](https://holidayextras.imgix.net/img/hilton.png?w=104&txt=%C2%A3186.00)](https://example.com/hilton) [![Metropole](https://holidayextras.imgix.net/img/metropole.png?w=104&txt=%C2%A3186.00)](https://example.com/metropole)
      """
    let segments = MarkdownSegmentParser.parse(input)

    XCTAssertEqual(segments.count, 1)
    if case .imageCarousel(let images) = segments.first {
      XCTAssertEqual(images.count, 4)
      XCTAssertEqual(images[0].alt, "Novotel")
      XCTAssertEqual(images[0].destination, "https://example.com/novotel")
      XCTAssertTrue(images[0].source.contains("txt=%C2%A3220.00"))
      XCTAssertEqual(images[1].alt, "Ibis")
      XCTAssertEqual(images[1].destination, "https://example.com/ibis")
      XCTAssertEqual(images[2].alt, "Hilton")
      XCTAssertEqual(images[2].destination, "https://example.com/hilton")
      XCTAssertEqual(images[3].alt, "Metropole")
      XCTAssertEqual(images[3].destination, "https://example.com/metropole")
    } else {
      XCTFail("Expected a single imageCarousel segment with linked images")
    }
  }

  func testRoundTripThroughCmarkPreservesHotelImages() {
    let content = MarkdownContent(hotelCarousel)
    let rendered = content.renderMarkdown()
    let segments = MarkdownSegmentParser.parse(rendered)

    XCTAssertEqual(segments.count, 1)
    if case .imageCarousel(let images) = segments.first {
      XCTAssertEqual(images.count, 4)
      XCTAssertEqual(images[0].alt, "Novotel")
      XCTAssertTrue(images[0].source.contains("txt=%C2%A3220.00"))
    } else {
      XCTFail("Expected imageCarousel after round-trip")
    }
  }
}
