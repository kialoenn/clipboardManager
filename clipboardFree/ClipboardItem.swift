import Cocoa
import SwiftUI

// Enum to define different types of clipboard items
enum ClipboardItem: Identifiable {
    case text(String)
    case image(NSImage)
    case file(String)

    var id: UUID {
        return UUID()
    }
}
