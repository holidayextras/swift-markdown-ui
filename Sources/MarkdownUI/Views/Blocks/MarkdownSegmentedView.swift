import SwiftUI

struct MarkdownSegmentedView: View {
  @Environment(\.theme) private var theme

  private let blocks: [BlockNode]

  init(_ blocks: [BlockNode]) {
    self.blocks = blocks
  }
    
  private var enumeratedGroups: [(offset: Int, element: BlockGroup)] {
    Array(self.groupedBlocks.enumerated())
  }
    
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
        ForEach(enumeratedGroups, id: \.offset) { _, group in
          switch group {
          case .blocks(let nodes):
            BlockSequence(nodes)
          case .carousel(let images):
            self.carouselView(for: images)
                  .padding(.top, 16)
                  .padding(.bottom, 24)
          }
        }
    }
  }

  @ViewBuilder
  private func carouselView(for images: [MarkdownImageItem]) -> some View {
    if images.count >= self.theme.carouselThreshold,
      let carousel = self.theme.carousel
    {
      carousel.makeBody(configuration: CarouselConfiguration(images: images))
    } else {
      HStack {
        ForEach(images.indices, id: \.self) { index in
          ImageView(data: images[index].rawImageData)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        Spacer()
      }
    } 
  }

  private enum BlockGroup {
    case blocks([BlockNode])
    case carousel([MarkdownImageItem])
  }

  private var groupedBlocks: [BlockGroup] {
    var groups: [BlockGroup] = []
    var currentBlocks: [BlockNode] = []

    for block in self.blocks {
      if let images = block.carouselImages {
        if !currentBlocks.isEmpty {
          groups.append(.blocks(currentBlocks))
          currentBlocks = []
        }
        groups.append(.carousel(images))
      } else {
        currentBlocks.append(block)
      }
    }

    if !currentBlocks.isEmpty {
      groups.append(.blocks(currentBlocks))
    }

    return groups
  }
}
