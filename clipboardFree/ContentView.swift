import SwiftUI

struct ContentView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    
    var body: some View {
        VStack {
            Text("Clipboard")
                .font(.headline)
                .foregroundColor(.white) // White title for contrast
                .padding(.top)
            
            List {
                ForEach(clipboardManager.clipboardHistory.reversed()) { item in
                    ClipboardRowView(item: item, clipboardManager: clipboardManager)
                }
            }
            .frame(minWidth: 300, minHeight: 400)
            .listStyle(PlainListStyle()) // Plain list style to remove default spacing
            .scrollContentBackground(.hidden) // Remove list background
        }
        .padding()
        .background(Color.gray.opacity(0.9)) // Dark background using built-in colors
        .frame(minWidth: 300, minHeight: 400)
        .shadow(radius: 4) // Optional shadow for the overall container
    }
}

struct ClipboardRowView: View {
    var item: ClipboardItem
    @ObservedObject var clipboardManager: ClipboardManager
    
    @State private var isHighlighted = false
    @State private var borderColor: Color = Color.clear // Default no border
    
    var body: some View {
        contentForItem(item)
            .frame(width: 250, height: 70) // Fixed width and height for each item, align to top-left
            .padding() // Padding around the content (text/image) within the item
            .background(Color.white) // White background for items, highlight with green
            .border(borderColor, width: 3) // Dynamic border color and width
            .clipped() // Clip content to avoid overflow beyond the defined frame
            .contentShape(Rectangle()) // No rounded corners
            .onTapGesture {
                clipboardManager.copyToClipboard(item: item)
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHighlighted = true
                    borderColor = Color.blue // Set border color to blue when clicked
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isHighlighted = false
                        borderColor = Color.clear // Revert border color after delay
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
                .font(.system(size: 16))
                .foregroundColor(.black)
                .truncationMode(.tail) // Truncate overflowing text with ellipses
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading) // Align text to top-left
        case .image(let image):
            Image(nsImage: image)
                .resizable()
                .scaledToFit()
                .frame(height: 50) // Adjust the image height to fit the fixed item box
        case .file(let filePath):
            Text(filePath)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .truncationMode(.tail) // Truncate overflowing text with ellipses
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading) // Align text to top-left
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ClipboardManager())
    }
}
