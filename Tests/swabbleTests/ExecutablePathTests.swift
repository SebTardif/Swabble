import Foundation
@testable import Swabble
import Testing

@Test
func `absolute executable path keeps an absolute symlink`() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent("swabble-exe-\(UUID().uuidString)", isDirectory: true)
    let versionOne = root.appendingPathComponent("v1", isDirectory: true)
    let versionTwo = root.appendingPathComponent("v2", isDirectory: true)
    let bin = root.appendingPathComponent("bin", isDirectory: true)
    try FileManager.default.createDirectory(at: versionOne, withIntermediateDirectories: true)
    try FileManager.default.createDirectory(at: versionTwo, withIntermediateDirectories: true)
    try FileManager.default.createDirectory(at: bin, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: root) }

    let oldBinary = versionOne.appendingPathComponent("swabble")
    let newBinary = versionTwo.appendingPathComponent("swabble")
    let link = bin.appendingPathComponent("swabble")
    try Data("old".utf8).write(to: oldBinary)
    try FileManager.default.createSymbolicLink(at: link, withDestinationURL: oldBinary)

    let stored = absoluteExecutablePath(raw: link.path)
    #expect(stored == link.path)
    #expect(stored != oldBinary.path)

    try Data("new".utf8).write(to: newBinary)
    try FileManager.default.removeItem(at: link)
    try FileManager.default.createSymbolicLink(at: link, withDestinationURL: newBinary)
    try FileManager.default.removeItem(at: oldBinary)

    #expect(FileManager.default.fileExists(atPath: stored))
    #expect(try String(contentsOf: URL(fileURLWithPath: stored), encoding: .utf8) == "new")
}

@Test
func `absolute executable path makes A relative invocation absolute`() {
    let stored = absoluteExecutablePath(raw: "bin/swabble")
    #expect(stored.hasPrefix("/"))
    #expect(stored.hasSuffix("/bin/swabble"))
}
