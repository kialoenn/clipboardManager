import SwiftUI

struct ContentView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    
    var body: some View {
        VStack {
            Text("Clipboard History")
                .font(.headline)
                .padding()
            
            List(clipboardManager.clipboardHistory.reversed()) { item in
                ClipboardRowView(item: item, clipboardManager: clipboardManager)
            }
            .frame(minWidth: 300, minHeight: 400)
        }
        .padding()
        .frame(minWidth: 300, minHeight: 400)
    }
}

struct ClipboardRowView: View {
    var item: ClipboardItem
    @ObservedObject var clipboardManager: ClipboardManager
    
    @State private var isHighlighted = false
    
    var body: some View {
        contentForItem(item)
            .background(isHighlighted ? Color.green.opacity(0.3) : Color.clear) // Highlight the copied item
            .contentShape(Rectangle())
            .onTapGesture {
                clipboardManager.copyToClipboard(item: item)
                withAnimation(.easeInOut(duration: 0.3)) {
                    isHighlighted = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isHighlighted = false
                    }
                }
            }
    }
    
    // Helper function to handle content rendering
    @ViewBuilder
    private func contentForItem(_ item: ClipboardItem) -> some View {
        switch item {
        case .text(let text):
            Text(text)
            
        case .image(let image):
            Image(nsImage: image)
                .resizable()
                .scaledToFit()
                .frame(height: 100)
            
        case .file(let filePath):
            Text(filePath)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ClipboardManager())
    }
}
