//
//  TimelineViewModelTests.swift
//  MemoryAtlas
//
//  Created by Chandresh Ahir on 9/24/26.
//

import XCTest
@testable import MemoryAtlas

final class MockMemoryRepository: MemoryRepository {
    var returnMemories: [Memory]
    var error: Error?
    var onFetch: (@MainActor () -> Void)?

    init(
        returnMemories: [Memory] = [],
        error: Error? = nil
    ) {
        self.returnMemories = returnMemories
        self.error = error
    }

    func fetchMemories() async throws -> [Memory] {
        await onFetch?()

        if let error {
            throw error
        }

        return returnMemories
    }

    func save(_ memory: Memory) async throws {}
}

@MainActor
final class TimelineViewModelTests: XCTestCase {
    
    func testInitialState() async throws {
        let viewModel = TimelineViewModel(memoryRepository: MockMemoryRepository())
        guard case .idle = viewModel.state else {
            return XCTFail("Expected the initial state to be idle")
        }
    }
    
    func testStateAfterFetch() async throws {
        let expectedMemories = [Memory(id: UUID(), title: "Test", note: nil, memoryDate: Date(), creationDate: Date())]
        let mock = MockMemoryRepository(returnMemories: expectedMemories)
        let viewModel = TimelineViewModel(memoryRepository: mock)
        
        await viewModel.load()
        
        guard case let .loaded(fetchedMemories) = viewModel.state else {
                return XCTFail("Expected loaded state, but got \(viewModel.state)")
            }
        
        XCTAssertEqual(fetchedMemories.count, 1)
        XCTAssertEqual(fetchedMemories.first?.title, "Test")
    }
    
    func testEmptyStateAfterFetch() async throws {
        let expectedMemories: [Memory] = []
        let mock = MockMemoryRepository(returnMemories: expectedMemories)
        let viewModel = TimelineViewModel(memoryRepository: mock)
        
        await viewModel.load()
        
        guard case .empty = viewModel.state else {
            return XCTFail("Expected loaded state")
        }
        
    }
    
    func testFailureStateAfterFetch() async throws {
        enum TestError: Error {
            case fetchFailed
        }
        
        let mock = MockMemoryRepository(error: TestError.fetchFailed)
        let viewModel = TimelineViewModel(memoryRepository: mock)

        await viewModel.load()

        guard case let .failed(message) = viewModel.state else {
            return XCTFail("Expected failed state")
        }

        XCTAssertEqual(message, "Unable to load memories. Please try again.")
    }
    
    func testLoadingStateWhenFetching() async throws {
        let expectedMemories = [Memory(id: UUID(), title: "Test", note: nil, memoryDate: Date(), creationDate: Date())]
        let mock = MockMemoryRepository(returnMemories: expectedMemories)
        let viewModel = TimelineViewModel(memoryRepository: mock)
        var observedLoading = false

        mock.onFetch = {
            guard case .loading = viewModel.state else {
                return
            }

            observedLoading = true
        }

        await viewModel.load()

        XCTAssertTrue(observedLoading)
    }
}
