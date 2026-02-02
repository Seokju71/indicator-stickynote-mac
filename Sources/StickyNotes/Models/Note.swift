import Foundation
import CoreGraphics

struct Note: Identifiable, Codable {
    let id: UUID
    var content: String
    var color: NoteColor
    var frame: CGRect
    var lastModified: Date
    var isLocked: Bool
    
    init(id: UUID = UUID(), content: String = "", color: NoteColor = .yellow, frame: CGRect = CGRect(x: 100, y: 100, width: 300, height: 300), lastModified: Date = Date(), isLocked: Bool = false) {
        self.id = id
        self.content = content
        self.color = color
        self.frame = frame
        self.lastModified = lastModified
        self.isLocked = isLocked
    }
}

enum NoteColor: String, Codable, CaseIterable {
    case yellow
    case blue
    case green
    case pink
    case purple
    case white
    
    var hex: String {
        switch self {
        case .yellow: return "#FFF7D1" // Reverted to lighter pastel yellow
        case .blue: return "#81D4FA"   // Vivid Light Blue
        case .green: return "#A5D6A7"  // Vivid Green
        case .pink: return "#F48FB1"   // Vivid Pink
        case .purple: return "#CE93D8" // Vivid Purple
        case .white: return "#F5F5F5"  // Slightly darker white
        }
    }
}
