import MarkdownUI
import SwiftUI

struct CarouselDemoView: View {
  @State private var threshold = 4

  private let content = """
    The `.carousel` theme modifier lets you customize how image-only
    paragraphs are rendered. When set, the library detects paragraphs
    that contain only images and passes them to your closure.

    ## Single Image (1)

    ![Mountain](https://picsum.photos/id/29/400/300)

    ## Two Images (2)

    [![City](https://picsum.photos/id/26/400/300)](https://example.com/city) [![Park](https://picsum.photos/id/28/400/300)](https://example.com/park)

    ## Three Images (3)

    ![Forest](https://picsum.photos/id/15/400/300) ![Lake](https://picsum.photos/id/16/400/300) ![Beach](https://picsum.photos/id/17/400/300)

    ## Four Linked Images (4)

    [![Sunset](https://picsum.photos/id/36/400/300)](https://example.com/sunset) [![River](https://picsum.photos/id/40/400/300)](https://example.com/river) [![Field](https://picsum.photos/id/41/400/300)](https://example.com/field) [![Coast](https://picsum.photos/id/42/400/300)](https://example.com/coast)

    ## Five Mixed Images (5)

    [![Hills](https://picsum.photos/id/50/400/300)](https://example.com/hills) ![Bridge](https://picsum.photos/id/53/400/300) [![Desert](https://picsum.photos/id/56/400/300)](https://example.com/desert) ![Snow](https://picsum.photos/id/59/400/300) [![Waterfall](https://picsum.photos/id/62/400/300)](https://example.com/waterfall)
    """

  var body: some View {
    DemoView(themeOptions: []) {
      Section(
        footer: Text("Minimum number of images in a paragraph to trigger carousel rendering.")
      ) {
        Stepper("Threshold: \(threshold)", value: $threshold, in: 1...5)
      }

      Section("Carousel") {
        Markdown(self.content)
          .markdownTheme(
            Theme.gitHub.carousel(threshold: threshold) { configuration in
              ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                  ForEach(configuration.images, id: \.self) { image in
                    carouselImage(image)
                  }
                }
                .padding(.vertical, 8)
              }
            }
          )
      }
    }
  }

  @ViewBuilder
  private func carouselImage(_ image: MarkdownImageItem) -> some View {
    let imageView = AsyncImage(url: URL(string: image.source)) { phase in
      switch phase {
      case .success(let loadedImage):
        loadedImage
          .resizable()
          .aspectRatio(contentMode: .fill)
      case .failure:
        Image(systemName: "photo")
          .foregroundColor(.secondary)
      default:
        ProgressView()
      }
    }
    .frame(width: 200, height: 150)
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .overlay(alignment: .bottom) {
      Text(image.alt)
        .font(.caption)
        .padding(4)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
      }

    if let destination = image.destination, let url = URL(string: destination) {
      Link(destination: url) {
        imageView
      }
    } else {
      imageView
    }
  }
}

struct CarouselDemoView_Previews: PreviewProvider {
  static var previews: some View {
    CarouselDemoView()
  }
}
