import XCTest

@testable import MarkdownUI

final class CarouselDetectionTests: XCTestCase {
  // MARK: - BlockNode.carouselImages

  func testStandaloneImageParagraph() {
    let block = BlockNode.paragraph(content: [
      .image(source: "https://example.com/img.png", children: [.text("alt")])
    ])

    let images = block.carouselImages
    XCTAssertEqual(images?.count, 1)
    XCTAssertEqual(images?[0].source, "https://example.com/img.png")
    XCTAssertEqual(images?[0].alt, "alt")
    XCTAssertNil(images?[0].destination)
  }

  func testLinkedImageParagraph() {
    let block = BlockNode.paragraph(content: [
      .link(destination: "https://example.com", children: [
        .image(source: "https://example.com/img.png", children: [.text("alt")])
      ])
    ])

    let images = block.carouselImages
    XCTAssertEqual(images?.count, 1)
    XCTAssertEqual(images?[0].source, "https://example.com/img.png")
    XCTAssertEqual(images?[0].alt, "alt")
    XCTAssertEqual(images?[0].destination, "https://example.com")
  }

  func testMultipleImagesWithWhitespace() {
    let block = BlockNode.paragraph(content: [
      .image(source: "https://example.com/1.png", children: [.text("first")]),
      .text(" "),
      .image(source: "https://example.com/2.png", children: [.text("second")]),
    ])

    let images = block.carouselImages
    XCTAssertEqual(images?.count, 2)
    XCTAssertEqual(images?[0].alt, "first")
    XCTAssertEqual(images?[1].alt, "second")
  }

  func testMixedLinkedAndStandaloneImages() {
    let block = BlockNode.paragraph(content: [
      .image(source: "https://example.com/1.png", children: [.text("a")]),
      .text(" "),
      .link(destination: "https://example.com/link", children: [
        .image(source: "https://example.com/2.png", children: [.text("b")])
      ]),
      .text(" "),
      .image(source: "https://example.com/3.png", children: [.text("c")]),
    ])

    let images = block.carouselImages
    XCTAssertEqual(images?.count, 3)
    XCTAssertEqual(images?[0].alt, "a")
    XCTAssertNil(images?[0].destination)
    XCTAssertEqual(images?[1].alt, "b")
    XCTAssertEqual(images?[1].destination, "https://example.com/link")
    XCTAssertEqual(images?[2].alt, "c")
    XCTAssertNil(images?[2].destination)
  }

  func testImagesWithSoftBreaks() {
    let block = BlockNode.paragraph(content: [
      .image(source: "https://example.com/1.png", children: [.text("first")]),
      .softBreak,
      .image(source: "https://example.com/2.png", children: [.text("second")]),
    ])

    let images = block.carouselImages
    XCTAssertEqual(images?.count, 2)
  }

  func testImagesWithLineBreaks() {
    let block = BlockNode.paragraph(content: [
      .image(source: "https://example.com/1.png", children: [.text("first")]),
      .lineBreak,
      .image(source: "https://example.com/2.png", children: [.text("second")]),
    ])

    let images = block.carouselImages
    XCTAssertEqual(images?.count, 2)
  }

  func testPlainTextReturnsNil() {
    let block = BlockNode.paragraph(content: [
      .text("Hello, world!")
    ])

    XCTAssertNil(block.carouselImages)
  }

  func testMixedTextAndImageReturnsNil() {
    let block = BlockNode.paragraph(content: [
      .text("Check out "),
      .image(source: "https://example.com/img.png", children: [.text("this")]),
      .text(" image"),
    ])

    XCTAssertNil(block.carouselImages)
  }

  func testHeadingReturnsNil() {
    let block = BlockNode.heading(level: 2, content: [.text("Title")])

    XCTAssertNil(block.carouselImages)
  }

  func testLinkWithoutImageReturnsNil() {
    let block = BlockNode.paragraph(content: [
      .link(destination: "https://example.com", children: [.text("click here")])
    ])

    XCTAssertNil(block.carouselImages)
  }

  func testEmptyParagraphReturnsNil() {
    let block = BlockNode.paragraph(content: [])

    XCTAssertNil(block.carouselImages)
  }

  // MARK: - Full markdown round-trip through MarkdownContent

  func testMarkdownStringWithCarouselImages() {
    let content = MarkdownContent(
      "![first](https://example.com/1.png) ![second](https://example.com/2.png)"
    )

    let images = content.blocks.first?.carouselImages
    XCTAssertEqual(images?.count, 2)
    XCTAssertEqual(images?[0].alt, "first")
    XCTAssertEqual(images?[1].alt, "second")
  }

  func testMarkdownStringWithLinkedImages() {
    let content = MarkdownContent(
      "[![City](https://example.com/city.png)](https://example.com/city) [![Park](https://example.com/park.png)](https://example.com/park)"
    )

    let images = content.blocks.first?.carouselImages
    XCTAssertEqual(images?.count, 2)
    XCTAssertEqual(images?[0].alt, "City")
    XCTAssertEqual(images?[0].destination, "https://example.com/city")
    XCTAssertEqual(images?[1].alt, "Park")
    XCTAssertEqual(images?[1].destination, "https://example.com/park")
  }

  func testRealWorldImgixURLs() {
    let content = MarkdownContent(
      """
      ![Novotel](https://holidayextras.imgix.net/img/novotel.png?w=104&txt=%C2%A3220.00) \
      ![Ibis](https://holidayextras.imgix.net/img/ibis.png?w=104&txt=%C2%A3162.00) \
      ![Hilton](https://holidayextras.imgix.net/img/hilton.png?w=104&txt=%C2%A3186.00) \
      ![Metropole](https://holidayextras.imgix.net/img/metropole.png?w=104&txt=%C2%A3186.00)
      """
    )

    let images = content.blocks.first?.carouselImages
    XCTAssertEqual(images?.count, 4)
    XCTAssertEqual(images?[0].alt, "Novotel")
    XCTAssertTrue(images?[0].source.contains("txt=%C2%A3220.00") ?? false)
    XCTAssertEqual(images?[3].alt, "Metropole")
  }

  func testMultipleParagraphsWithCarousel() {
    let content = MarkdownContent(
      """
      # Hotels

      Choose a hotel:

      ![Hotel A](https://example.com/a.png) ![Hotel B](https://example.com/b.png)

      Book now!
      """
    )

    let blocks = content.blocks
    // heading, paragraph, image paragraph, paragraph
    XCTAssertNil(blocks[0].carouselImages) // heading
    XCTAssertNil(blocks[1].carouselImages) // "Choose a hotel:"
    XCTAssertEqual(blocks[2].carouselImages?.count, 2) // image paragraph
    XCTAssertNil(blocks[3].carouselImages) // "Book now!"
  }
}
