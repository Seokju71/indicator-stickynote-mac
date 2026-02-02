import Foundation
import SwiftUI
import Combine

class AppViewModel: ObservableObject {
    @Published var noteViewModels: [NoteViewModel] = []
    
    // Global Settings
    @Published var selectedFontName: String {
        didSet {
            UserDefaults.standard.set(selectedFontName, forKey: "selectedFontName")
        }
    }
    @Published var selectedFontSize: Double {
        didSet {
            UserDefaults.standard.set(selectedFontSize, forKey: "selectedFontSize")
        }
    }
    
    private let saveFileName = "stickynotes.json"
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.selectedFontName = UserDefaults.standard.string(forKey: "selectedFontName") ?? "Helvetica"
        self.selectedFontSize = UserDefaults.standard.double(forKey: "selectedFontSize") == 0 ? 14.0 : UserDefaults.standard.double(forKey: "selectedFontSize")
        
        loadNotes()
        
        // Auto-save whenever any note changes
        // This is a simplified approach. In a real app, we might want more granular saving.
        $noteViewModels
            .sink { [weak self] _ in
                self?.setupNoteObservers()
            }
            .store(in: &cancellables)
    }
    
    private func setupNoteObservers() {
        // Observe changes in each note to trigger save
        // Clearing old observers
        cancellables.removeAll()
        
        // Re-observe the list itself
        $noteViewModels
            .sink { [weak self] _ in
                self?.saveNotes() // Save on structural changes (add/remove)
            }
            .store(in: &cancellables)
            
        // Observe individual note changes
        for viewModel in noteViewModels {
            viewModel.objectWillChange
                .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
                .sink { [weak self] _ in
                    self?.saveNotes()
                }
                .store(in: &cancellables)
        }
    }
    
    func addNote() {
        var newFrame = CGRect(x: 100, y: 100, width: 300, height: 300)
        var newColor: NoteColor = .yellow
        
        if let lastNote = noteViewModels.last {
            // Inherit size from last note
            let lastFrame = lastNote.frame
            // Cascade position slightly
            newFrame = CGRect(
                x: lastFrame.origin.x + 30,
                y: lastFrame.origin.y + 30,
                width: lastFrame.width,
                height: lastFrame.height
            )
            
            // Cycle color
            if let currentIndex = NoteColor.allCases.firstIndex(of: lastNote.color) {
                let nextIndex = (currentIndex + 1) % NoteColor.allCases.count
                newColor = NoteColor.allCases[nextIndex]
            }
        }
        
        let newNote = Note(content: "", color: newColor, frame: newFrame)
        let viewModel = NoteViewModel(note: newNote)
        noteViewModels.append(viewModel)
        // Setup observers again for the new note
        setupNoteObservers() 
    }
    
    func deleteNote(id: UUID) {
        noteViewModels.removeAll { $0.id == id }
    }
    
    func showAll() {
        // Logic to bring all windows to front (handled in View layer usually, but logic here)
    }
    
    func hideAll() {
        // Logic to hide windows
    }
    
    // MARK: - Persistence
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let directory = paths[0].appendingPathComponent("StickyNotes")
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
    
    private func saveNotes() {
        let notes = noteViewModels.map { $0.note }
        let url = getDocumentsDirectory().appendingPathComponent(saveFileName)
        
        do {
            let data = try JSONEncoder().encode(notes)
            try data.write(to: url)
            print("Saved notes to \(url)")
        } catch {
            print("Failed to save notes: \(error)")
        }
    }
    
    private func loadNotes() {
        let url = getDocumentsDirectory().appendingPathComponent(saveFileName)
        
        guard let data = try? Data(contentsOf: url) else {
            // First run or no data
            if noteViewModels.isEmpty {
                addNote() // Start with one note if empty
            }
            return
        }
        
        do {
            let notes = try JSONDecoder().decode([Note].self, from: data)
            self.noteViewModels = notes.map { NoteViewModel(note: $0) }
            self.setupNoteObservers()
        } catch {
            print("Failed to load notes: \(error)")
            addNote() // Fallback
            addNote() // Fallback
        }
    }
    
    // MARK: - Storage Management
    
    var storageUsage: String {
        let url = getDocumentsDirectory().appendingPathComponent(saveFileName)
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
              let size = attributes[.size] as? Int64 else {
            return "0 KB"
        }
        return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
    
    func clearAllData() {
        let url = getDocumentsDirectory().appendingPathComponent(saveFileName)
        try? FileManager.default.removeItem(at: url)
        
        // Remove all notes from memory
        noteViewModels.removeAll()
        
        // Reset to default settings if desired, or keep them? User said "Clear memo content"
        // Let's create one fresh empty note
        addNote()
    }
}
