import Cocoa
import SwiftUI

class FloatingWindow: NSWindow {
    var viewModel: NoteViewModel?
    
    init(viewModel: NoteViewModel, appViewModel: AppViewModel) {
        self.viewModel = viewModel
        
        
        let styleMask: NSWindow.StyleMask = [.borderless, .resizable, .fullSizeContentView]
        
        super.init(
            contentRect: viewModel.frame,
            styleMask: styleMask,
            backing: .buffered,
            defer: false
        )
        
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = true
        self.level = .floating
        self.isMovableByWindowBackground = true
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.isReleasedWhenClosed = false // Critical: Prevent double-free when managing windows manually
        
        // Setup Content View
        let noteView = NoteView(viewModel: viewModel, appViewModel: appViewModel)
        self.contentView = NSHostingView(rootView: noteView)
        
        // Restore position/size
        self.setFrame(viewModel.frame, display: true)
        
        // Ensure application is active so window can become key
        NSApp.activate(ignoringOtherApps: true)
        
        // Observe frame changes to autosave position
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidMove), name: NSWindow.didMoveNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidResize), name: NSWindow.didResizeNotification, object: self)
    }
    
    @objc func windowDidMove() {
        viewModel?.frame = self.frame
    }
    
    @objc func windowDidResize() {
        viewModel?.frame = self.frame
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
}
