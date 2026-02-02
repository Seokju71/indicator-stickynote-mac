import SwiftUI
import AppKit

struct CustomTextView: NSViewRepresentable {
    @Binding var text: String
    var fontName: String
    var fontSize: Double

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        guard let textView = scrollView.documentView as? NSTextView else { return scrollView }
        
        textView.drawsBackground = false
        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.font = NSFont(name: fontName, size: fontSize) ?? .systemFont(ofSize: fontSize)
        textView.textColor = .black
        textView.insertionPointColor = .black // Ensure cursor is visible
        
        // Allow unlimited height
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        
        // Add padding (margins)
        textView.textContainerInset = NSSize(width: 8, height: 4)
        
        // Add line spacing
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4 // Adjust this value for line height
        
        textView.defaultParagraphStyle = paragraphStyle
        textView.typingAttributes[.paragraphStyle] = paragraphStyle
        
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        
        // Update text only if changed to avoid cursor jumping or loops
        if textView.string != text {
            textView.string = text
        }
        
        // Update font dynamically
        let currentFont = textView.font
        if currentFont?.fontName != fontName || currentFont?.pointSize != CGFloat(fontSize) {
            textView.font = NSFont(name: fontName, size: fontSize) ?? .systemFont(ofSize: fontSize)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: CustomTextView

        init(_ parent: CustomTextView) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            // Update binding
            parent.text = textView.string
        }
    }
}
