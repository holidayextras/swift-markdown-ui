import SwiftUI

extension Color {
  /// Creates a constant color from an RGBA value.
  /// - Parameter rgba: A 32-bit value that represents the red, green, blue, and alpha components of the color.
  public init(rgba: UInt32) {
    self.init(
      red: CGFloat((rgba & 0xff00_0000) >> 24) / 255.0,
      green: CGFloat((rgba & 0x00ff_0000) >> 16) / 255.0,
      blue: CGFloat((rgba & 0x0000_ff00) >> 8) / 255.0,
      opacity: CGFloat(rgba & 0x0000_00ff) / 255.0
    )
  }

  /// Blends this color with another color using the given factor.
  /// - Parameters:
  ///   - other: The color to blend with.
  ///   - factor: A value between 0 and 1. A factor of 0 returns the original color, a factor of 1 returns the other color.
  /// - Returns: The blended color.
  public func blended(with other: Color, factor: Double) -> Color {
    let factor = max(0, min(1, factor))

    #if canImport(UIKit)
    let selfComponents = UIColor(self).cgColor.components ?? [0, 0, 0, 1]
    let otherComponents = UIColor(other).cgColor.components ?? [0, 0, 0, 1]
    #elseif canImport(AppKit)
    let selfNS = NSColor(self).usingColorSpace(.deviceRGB) ?? NSColor.black
    let otherNS = NSColor(other).usingColorSpace(.deviceRGB) ?? NSColor.black
    let selfComponents = [selfNS.redComponent, selfNS.greenComponent, selfNS.blueComponent, selfNS.alphaComponent]
    let otherComponents = [otherNS.redComponent, otherNS.greenComponent, otherNS.blueComponent, otherNS.alphaComponent]
    #endif

    // Handle grayscale colors (2 components: gray + alpha)
    let selfRed = selfComponents.count >= 3 ? selfComponents[0] : selfComponents[0]
    let selfGreen = selfComponents.count >= 3 ? selfComponents[1] : selfComponents[0]
    let selfBlue = selfComponents.count >= 3 ? selfComponents[2] : selfComponents[0]
    let selfAlpha = selfComponents.count >= 4 ? selfComponents[3] : (selfComponents.count >= 2 ? selfComponents[1] : 1.0)

    let otherRed = otherComponents.count >= 3 ? otherComponents[0] : otherComponents[0]
    let otherGreen = otherComponents.count >= 3 ? otherComponents[1] : otherComponents[0]
    let otherBlue = otherComponents.count >= 3 ? otherComponents[2] : otherComponents[0]
    let otherAlpha = otherComponents.count >= 4 ? otherComponents[3] : (otherComponents.count >= 2 ? otherComponents[1] : 1.0)

    return Color(
      red: selfRed + (otherRed - selfRed) * factor,
      green: selfGreen + (otherGreen - selfGreen) * factor,
      blue: selfBlue + (otherBlue - selfBlue) * factor,
      opacity: selfAlpha + (otherAlpha - selfAlpha) * factor
    )
  }

  /// Returns a color from a gradient at the given progress.
  ///
  /// Use this method to get an interpolated color at any position along a gradient.
  /// This is useful for creating per-character gradient text effects.
  ///
  /// ```swift
  /// let colors: [Color] = [.blue, .purple, .pink]
  /// let midColor = Color.gradientColor(from: colors, at: 0.5) // Returns purple
  /// ```
  ///
  /// - Parameters:
  ///   - colors: The colors in the gradient.
  ///   - progress: A value between 0 and 1 representing position in the gradient.
  /// - Returns: The interpolated color at the given progress.
  public static func gradientColor(from colors: [Color], at progress: Double) -> Color {
    guard colors.count > 1 else {
      return colors.first ?? .primary
    }

    let scaled = progress * Double(colors.count - 1)
    let lowerIndex = Int(scaled)
    let upperIndex = min(lowerIndex + 1, colors.count - 1)
    let blendFactor = scaled - Double(lowerIndex)

    return colors[lowerIndex].blended(with: colors[upperIndex], factor: blendFactor)
  }

  /// Creates a context-dependent color with different values for light and dark appearances.
  /// - Parameters:
  ///   - light: The light appearance color value.
  ///   - dark: The dark appearance color value.
  public init(light: @escaping @autoclosure () -> Color, dark: @escaping @autoclosure () -> Color) {
    #if os(watchOS)
      self = dark()
    #elseif canImport(UIKit)
      self.init(
        uiColor: .init { traitCollection in
          switch traitCollection.userInterfaceStyle {
          case .unspecified, .light:
            return UIColor(light())
          case .dark:
            return UIColor(dark())
          @unknown default:
            return UIColor(light())
          }
        }
      )
    #elseif canImport(AppKit)
      self.init(
        nsColor: .init(name: nil) { appearance in
          if appearance.bestMatch(from: [.aqua, .darkAqua]) == .aqua {
            return NSColor(light())
          } else {
            return NSColor(dark())
          }
        }
      )
    #endif
  }
}
