import XCTest
import SwiftTreeSitter
import TreeSitterConcerto

final class TreeSitterConcertoTests: XCTestCase {
    func testCanLoadGrammar() throws {
        let parser = Parser()
        let language = Language(language: tree_sitter_concerto())
        XCTAssertNoThrow(try parser.setLanguage(language),
                         "Error loading Concerto grammar")
    }
}
