import SwiftUI
import Combine

@main
struct StickyNotesApp: App {
    // We use a simplified approach: The AppViewModel lives in the delegate 
    // and the delegate manages the NSWindows directly.
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            SettingsView(appViewModel: appDelegate.appViewModel)
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Sticky Notes") {
                    NSApp.orderFrontStandardAboutPanel(options: [
                        NSApplication.AboutPanelOptionKey.applicationName: "Sticky Notes",
                        NSApplication.AboutPanelOptionKey.applicationVersion: "0.1",
                        NSApplication.AboutPanelOptionKey.version: "Build 1"
                    ])
                }
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var appViewModel = AppViewModel()
    var windows: [UUID: FloatingWindow] = [:]
    
    var cancellables = Set<AnyCancellable>()
    
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Ensure the app runs as a regular GUI app (critical for receiving keyboard focus)
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true) // Force focus on launch
        
        // Setup Status Bar Item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "note.text", accessibilityDescription: "Sticky Notes")
            button.action = #selector(toggleAppVisibility)
            button.target = self
        }
        
        // Observe NoteViewModels to open/close windows
        appViewModel.$noteViewModels
            .receive(on: RunLoop.main) // Ensure UI updates on main thread
            .sink { [weak self] viewModels in
                self?.syncWindows(with: viewModels)
            }
            .store(in: &cancellables)
    }
    
    @objc func toggleAppVisibility() {
        if NSApp.isHidden {
            NSApp.unhide(nil)
            NSApp.activate(ignoringOtherApps: true)
        } else {
            NSApp.hide(nil)
        }
    }
    
    func syncWindows(with viewModels: [NoteViewModel]) {
        let currentIDs = Set(viewModels.map { $0.id })
        
        // Remove closed windows
        let windowsToRemove = windows.keys.filter { !currentIDs.contains($0) }
        
        for id in windowsToRemove {
            if let window = windows[id] {
                window.close()
                windows.removeValue(forKey: id)
            }
        }
        
        // Add new windows
        for viewModel in viewModels {
            if windows[viewModel.id] == nil {
                let window = FloatingWindow(viewModel: viewModel, appViewModel: appViewModel)
                window.makeKeyAndOrderFront(nil)
                windows[viewModel.id] = window
            }
        }
    }
    
    // Terminate check removed or modified?
    // User wants "Tray icon to restore", so if we close/hide, app shouldn't quit.
    // However, if we DELETE all notes, we might want to stay open in tray?
    // Let's remove this automatic termination so the app stays in tray.
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true 
    }
}
