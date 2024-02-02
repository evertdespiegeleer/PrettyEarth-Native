// Thanks @lucasfeijo!
// https://gist.github.com/Amzd/cb8ba40625aeb6a015101d357acaad88

import SwiftUI

extension View {
  public func cursor(_ cursor: NSCursor) -> some View {
    if #available(macOS 13.0, *) {
      return self.onContinuousHover { phase in
        switch phase {
        case .active(let p):
          cursor.push()
        case .ended:
          NSCursor.pop()
        }
      }
    } else {
      return self.onHover { inside in
        if inside {
          cursor.push()
        } else {
          NSCursor.pop()
        }
      }
    }
  }
}
