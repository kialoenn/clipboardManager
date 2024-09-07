import Cocoa
import SwiftUI
import Combine

class ClipboardManager: ObservableObject {
    @Published var clipboardHistory: [ClipboardItem] = []
    private var textSet: Set<String> = []
    private var timer: Timer?
    private let maxHistorySize = 25
    private let maxItemSize: Int = 4 * 1024 * 1024 // 4 MB in bytes random test

    init() {
        startClipboardMonitoring()
    }

    func startClipboardMonitoring() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkClipboard), userInfo: nil, repeats: true)
    }

    @objc func checkClipboard() {
        let pasteboard = NSPasteboard.general

        // Check for text
        if let copiedText = pasteboard.string(forType: .string) {
            if textSet.contains(copiedText) {
                // Text already exists in the history
            } else if let textSize = copiedText.data(using: .utf8)?.count, textSize <= maxItemSize {
                DispatchQueue.main.async {
                    self.addClipboardItem(.text(copiedText))
                }
            }
        }

        // Check for images
        if let copiedImage = pasteboard.data(forType: .tiff), let image = NSImage(data: copiedImage) {
            if case let .image(lastImage) = clipboardHistory.last, lastImage.tiffRepresentation == image.tiffRepresentation {
                // Already in history
            } else if copiedImage.count <= maxItemSize {
                DispatchQueue.main.async {
                    self.addClipboardItem(.image(image))
                }
            }
        }

        // Check for files
        if let copiedFiles = pasteboard.propertyList(forType: .fileURL) as? [String], !copiedFiles.isEmpty {
            if case let .file(lastFiles) = clipboardHistory.last, lastFiles == copiedFiles.first {
                // Already in history
            } else {
                for file in copiedFiles {
                    let fileSize = getFileSize(filePath: file)
                    if fileSize <= maxItemSize {
                        DispatchQueue.main.async {
                            self.addClipboardItem(.file(file))
                        }
                    }
                }
            }
        }
    }
    
    private func addClipboardItem(_ item: ClipboardItem) {
        switch item {
        case .text(let text):
            textSet.insert(text)
        case .image(_):
            break
        case .file(_):
            break
        }
        
        clipboardHistory.append(item)
        
        if clipboardHistory.count > maxHistorySize {
            let removedItem = clipboardHistory.removeFirst()
            if case let .text(removedText) = removedItem {
                textSet.remove(removedText)
            }
        }
    }
    
    private func getFileSize(filePath: String) -> Int {
        if let fileURL = URL(string: filePath) {
            do {
                let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                return resourceValues.fileSize ?? 0
            } catch {
                print("Failed to get file size: \(error)")
            }
        }
        return 0
    }

    func copyToClipboard(item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        switch item {
        case .text(let text):
            pasteboard.setString(text, forType: .string)
        case .image(let image):
            if let tiffData = image.tiffRepresentation {
                pasteboard.setData(tiffData, forType: .tiff)
            }
        case .file(let filePath):
            if let fileURL = URL(string: filePath) {
                pasteboard.setPropertyList([fileURL.absoluteString], forType: .fileURL)
            }
        }
    }
}
