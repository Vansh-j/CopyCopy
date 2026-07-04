import Foundation
import AppKit
import ArgumentParser

@main
struct Cpcp: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "cpcp",
        abstract: "A smarter macOS clipboard copy utility."
    )

    @Flag(name: .shortAndLong, help: "Keep raw formatting (don't strip trailing newlines or ANSI).")
    var raw = false
    
    // NEW FLAG: To force literal text mode, bypassing file detection
    @Flag(name: [.customShort("t"), .long], help: "Force input to be treated as literal text (bypasses file auto-detection).")
    var textOnly = false

    @Argument(help: "Text or file to copy.")
    var input: [String] = []

    func run() throws {
        let hasStdin = isatty(STDIN_FILENO) == 0
        let hasArgs = !input.isEmpty

        if hasStdin && hasArgs {
            printError("❌ Error: Cannot read from both stdin and arguments simultaneously.")
            Darwin.exit(1)
        }

        let pb = NSPasteboard.general
        pb.clearContents()

        if hasArgs {
            let argString = input.joined(separator: " ")
            let fm = FileManager.default
            
            // FIXED: Now checks if user forced text mode before looking for files
            if !textOnly && fm.fileExists(atPath: argString) {
                let url = URL(fileURLWithPath: argString)
                
                if let text = try? String(contentsOf: url, encoding: .utf8) {
                    _ = processAndCopy(text: text, pb: pb)
                    printFeedback("✔ Copied text contents of \(url.lastPathComponent)")
                } else {
                    let item = NSPasteboardItem()
                    item.setString(url.absoluteString, forType: .fileURL)
                    
                    if let typeString = try? NSWorkspace.shared.type(ofFile: url.path),
                       let fileData = try? Data(contentsOf: url) {
                        
                        let pasteboardType = NSPasteboard.PasteboardType(typeString)
                        item.setData(fileData, forType: pasteboardType)
                    }
                    
                    pb.writeObjects([item])
                    printFeedback("✔ Copied file asset: \(url.lastPathComponent)")
                }
            } else {
                // FIXED: Capture the returned clean string to count it
                let finalStr = processAndCopy(text: argString, pb: pb)
                printFeedback("✔ Copied \(finalStr.count) characters")
            }
        } else if hasStdin {
            let data = FileHandle.standardInput.readDataToEndOfFile()
            guard let text = String(data: data, encoding: .utf8) else {
                printError("❌ Error: Could not read standard input as text.")
                Darwin.exit(1)
            }
            // FIXED: Capture the returned clean string to count it
            let finalStr = processAndCopy(text: text, pb: pb)
            printFeedback("✔ Copied \(finalStr.count) characters from pipe")
        } else {
            printError(Cpcp.helpMessage())
            Darwin.exit(1)
        }
    }

    // FIXED: Now returns the modified String so we can count it accurately
    func processAndCopy(text: String, pb: NSPasteboard) -> String {
        var finalText = text
        
        if !raw {
            let ansiPattern = "\u{001B}\\[[0-9;]*[a-zA-Z]"
            if let regex = try? NSRegularExpression(pattern: ansiPattern, options: []) {
                let range = NSRange(location: 0, length: finalText.utf16.count)
                finalText = regex.stringByReplacingMatches(in: finalText, options: [], range: range, withTemplate: "")
            }
            finalText = finalText.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
        }
        
        pb.setString(finalText, forType: .string)
        return finalText
    }

    func printError(_ message: String) {
        if let data = (message + "\n").data(using: .utf8) {
            FileHandle.standardError.write(data)
        }
    }

    func printFeedback(_ message: String) {
        if isatty(STDERR_FILENO) != 0 {
            printError(message)
        }
    }
}