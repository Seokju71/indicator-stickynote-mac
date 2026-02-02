import Foundation
import SwiftUI
import Combine

class NoteViewModel: ObservableObject, Identifiable {
    @Published var note: Note
    private var cancellables = Set<AnyCancellable>()
    
    var id: UUID { note.id }
    
    var content: String {
        get { note.content }
        set { 
            note.content = newValue 
            note.lastModified = Date()
        }
    }
    
    var color: NoteColor {
        get { note.color }
        set { note.color = newValue }
    }
    
    var frame: CGRect {
        get { note.frame }
        set { note.frame = newValue }
    }
    
    var isLocked: Bool {
        get { note.isLocked }
        set { note.isLocked = newValue }
    }
    
    init(note: Note) {
        self.note = note
        
        // Auto-save logic could be triggered here or in the parent AppViewModel
        // For simple MVVM, we can let AppViewModel observe changes in its children if needed,
        // or just have the View trigger save on change.
        // For now, we exposes properties that update the underlying model.
    }
    
    func updateColor(_ newColor: NoteColor) {
        self.color = newColor
        self.objectWillChange.send()
    }
}
