//
//  TodoListProjectTests.swift
//  TodoListProjectTests
//
//  Created by Максим on 08.07.2023.
//

import XCTest
@testable import TodoListProject

final class TodoListProjectTests: XCTestCase {

    //private let session = URLSession.shared
    private let fileContents = "Hello, world!"
    private var fileURL: URL!
    
    override func setUpWithError() throws {
        let fileName = "TodoListProjectTests-" + UUID().uuidString
        fileURL = URL(fileURLWithPath: NSTemporaryDirectory() + fileName)
        try Data(fileContents.utf8).write(to: fileURL)
    }

    override func tearDownWithError() throws {
        super.tearDown()
        try? FileManager.default.removeItem(at: fileURL)
    }

    
    func testURLRequestNoError() async throws {
        let request = URLRequest(url: fileURL)
        let (data, response) = try await URLSession.shared.dataTask(for: request)
        let string = String(decoding: data, as: UTF8.self)
        XCTAssertEqual(string, fileContents)
        XCTAssertEqual(response.url, fileURL)
        
    }
    
    func testURLRequestWithError() async throws {
        let invalidURL = fileURL.appendingPathComponent("doesNotExist")
        let request = URLRequest(url: invalidURL)
        do {
            _ = try await URLSession.shared.dataTask(for: request)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue("\(error)".contains(invalidURL.absoluteString))
        }
    }
    
    func testCancelling() async throws {
        let task = Task {
            do {
                let fileContents = "Hello, world!"
                let fileName = "TodoListProjectTests-" + UUID().uuidString
                let fileURLT = URL(fileURLWithPath: NSTemporaryDirectory() + fileName)
                try Data(fileContents.utf8).write(to: fileURLT)
                let request = URLRequest(url: fileURLT)
                let (data, _) = try await URLSession.shared.dataTask(for: request)
                if Task.isCancelled { return 0 }
                
                return data.count
            } catch {
                if Task.isCancelled { return 0 }
                
                throw error
            }
        }
        
        task.cancel()
        let result = try await task.value
        
        XCTAssertEqual(result, 0)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
