import Foundation
import Testing
@testable import Swabble

@Test func absoluteExecutablePathIsAbsoluteAndExists() {
    let path = absoluteExecutablePath()
    #expect(path.hasPrefix("/"))
    #expect(FileManager.default.fileExists(atPath: path))
}
