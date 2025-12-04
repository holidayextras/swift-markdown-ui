import SwiftUI

struct InlineTextStyles {
  let code: TextStyle
  let emphasis: TextStyle
  let strong: TextStyle
  let strikethrough: TextStyle
  let link: TextStyle
  let customLink: ((LinkConfiguration) -> Text)?
}
