import SwiftUI

struct NoteView: View {
    @ObservedObject var viewModel: NoteViewModel
    @ObservedObject var appViewModel: AppViewModel // To trigger delete/new
    
    var body: some View {
        VStack(spacing: 0) {
            // Header / Toolbar
            // Header / Toolbar
            // Header / Toolbar
            // Header / Toolbar
            HStack(spacing: 8) {
                Button(action: {
                    appViewModel.addNote()
                }) {
                    Image(systemName: "plus")
                        .frame(width: 20, height: 20)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                // Draggable Area (Middle)
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(WindowDragGesture())
                
                // Color Picker
                Menu {
                    ForEach(NoteColor.allCases, id: \.self) { color in
                        Button(action: {
                            viewModel.updateColor(color)
                        }) {
                            HStack {
                                Circle().fill(Color(hex: color.hex))
                                Text(color.rawValue.capitalized)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "paintpalette.fill") // Use fill for better visibility
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16) // Slightly smaller icon feels cleaner
                        .padding(2)                 // Add padding to matching touch target
                        .foregroundColor(.black)     // Explicitly set black
                        .contentShape(Rectangle())
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
                .menuIndicator(.hidden)
                
                // Hide Button (Eye Slash)
                Button(action: {
                    NSApp.hide(nil)
                }) {
                    Image(systemName: "eye.slash")
                        .frame(width: 20, height: 20)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                // Delete Button (Trash)
                Button(action: {
                    appViewModel.deleteNote(id: viewModel.id)
                }) {
                    Image(systemName: "trash")
                        .frame(width: 20, height: 20)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(8)
            .frame(height: 36)
            .background(Color(hex: viewModel.color.hex).brightness(-0.05)) // Background for the whole header
            .foregroundColor(.black) // Force black icons
            
            // Content
            // Content
            CustomTextView(
                text: $viewModel.content,
                fontName: appViewModel.selectedFontName,
                fontSize: appViewModel.selectedFontSize
            )
            .padding(.top, 10) // Add margin between header and text
            .background(Color(hex: viewModel.color.hex))
        }
        .background(Color(hex: viewModel.color.hex))
        .cornerRadius(0)
        .padding(0)
        // Make the entire background draggable (excluding the TextEditor which consumes its own touches)
        .background(WindowAccessor { window in
             // Optional: Force make key if clicked?
             window?.makeKeyAndOrderFront(nil)
        })
    }
}

// Helper to move window via DragGesture
struct WindowDragGesture: Gesture {
    var body: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                // Find the window and move it
                if let window = NSApp.windows.first(where: { $0.isKeyWindow }) {
                     // Calculating delta requires global state or binding, which is hard in pure Gesture.
                     // The reliable standard macOS way:
                     window.performDrag(with: NSEvent()) 
                } else if let event = NSApp.currentEvent, let window = event.window {
                    window.performDrag(with: event)
                }
            }
    }
}

// Helper to access NSWindow from SwiftUI
struct WindowAccessor: NSViewRepresentable {
    var callback: (NSWindow?) -> Void
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            self.callback(view.window)
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
