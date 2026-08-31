import Foundation
import Testing
@testable import Swabble

@Test
func removeItemIgnoringNotFoundIgnoresMissingFile() throws {
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".plist")
    #expect(!FileManager.default.fileExists(atPath: url.path))
    try FileSystem.removeItemIgnoringNotFound(at: url)
}

@Test
func removeItemIgnoringNotFoundDeletesExistingFile() throws {
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".plist")
    try Data("keep-alive\n".utf8).write(to: url)
    defer { try? FileManager.default.removeItem(at: url) }

    try FileSystem.removeItemIgnoringNotFound(at: url)
    #expect(!FileManager.default.fileExists(atPath: url.path))
}

@Test
func removeItemIgnoringNotFoundRethrowsPermissionErrors() throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(
        UUID().uuidString,
        isDirectory: true,
    )
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    let url = directory.appendingPathComponent("com.swabble.agent.plist")
    try Data("keep-alive\n".utf8).write(to: url)
    defer {
        try? FileManager.default.setAttributes([.immutable: false], ofItemAtPath: url.path)
        try? FileManager.default.removeItem(at: directory)
    }
    try FileManager.default.setAttributes([.immutable: true], ofItemAtPath: url.path)

    var thrown: (any Error)?
    do {
        try FileSystem.removeItemIgnoringNotFound(at: url)
    } catch {
        thrown = error
    }

    #expect(thrown != nil)
    #expect(FileManager.default.fileExists(atPath: url.path))
    if let cocoa = thrown as? CocoaError {
        #expect(cocoa.code != .fileNoSuchFile)
    }
}
