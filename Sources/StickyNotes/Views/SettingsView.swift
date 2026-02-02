import SwiftUI
import AppKit

struct SettingsView: View {
    @ObservedObject var appViewModel: AppViewModel
    
    // We can get available fonts from NSFontManager
    let availableFonts: [String] = NSFontManager.shared.availableFontFamilies
    
    @State private var showClearConfirmation = false

    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            // Left Column: Storage
            VStack(alignment: .leading, spacing: 10) {
                Text("Storage")
                    .font(.headline)
                
                GroupBox {
                    VStack(alignment: .leading) {
                        Text("Usage: \(appViewModel.storageUsage)")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        
                        Divider()
                        
                        Button("Clear All Data") {
                            showClearConfirmation = true
                        }
                        .controlSize(.small)
                    }
                    .padding(4)
                }
                .frame(width: 150)
            }
            
            Divider()
            
            // Right Column: Appearance (Fonts)
            VStack(alignment: .leading, spacing: 10) {
                Text("Appearance")
                    .font(.headline)
                
                Form {
                    Picker("Font", selection: $appViewModel.selectedFontName) {
                        ForEach(availableFonts, id: \.self) { font in
                            Text(font).tag(font)
                                .font(.custom(font, size: 12))
                        }
                    }
                    .pickerStyle(.menu)
                    
                    HStack {
                        Text("Size: \(Int(appViewModel.selectedFontSize))")
                        Slider(value: $appViewModel.selectedFontSize, in: 10...36, step: 1)
                    }
                }
            }
        }
        .padding()
        .frame(width: 450, height: 220)
        .alert(isPresented: $showClearConfirmation) {
            Alert(
                title: Text("Clear All Data?"),
                message: Text("This will delete all sticky notes and cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    appViewModel.clearAllData()
                },
                secondaryButton: .cancel()
            )
        }
    }
}
