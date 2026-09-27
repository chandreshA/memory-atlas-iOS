//
//  CreateMemoryViewModelTests.swift
//  MemoryAtlas
//
//  Created by Chandresh Ahir on 9/26/26.
//

import XCTest
@testable import MemoryAtlas

final class SpyMemoryRepository: MemoryRepository {
    var savedMemories: [Memory] = []
    var saveCallCount = 0
    var saveError: Error?
    var onSave: (@MainActor () -> Void)?

    init(savedMemories: [Memory] = [], saveError: Error? = nil) {
        self.savedMemories = savedMemories
        self.saveError = saveError
    }

    func fetchMemories() async throws -> [Memory] {
        return []
    }

    func save(_ memory: Memory) async throws {
        saveCallCount += 1
        onSave?()
        if let saveError {
            throw saveError
        }
        savedMemories.append(memory)
    }
}

@MainActor
final class CreateMemoryViewModelTests: XCTestCase {

    func testInitialState() async throws {
        let viewModel = CreateMemoryViewModel(memoryRepository: SpyMemoryRepository())
        guard case .idle = viewModel.state else {
            return XCTFail("Expected the initial state to be idle")
        }
    }

    func testEmptyMemoryCanNotBeSaved() async throws {
        let mock = SpyMemoryRepository(savedMemories: [])
        let viewModel = CreateMemoryViewModel(memoryRepository: mock)

        await viewModel.save()

        guard case .failed(_) = viewModel.state else {
            return XCTFail("Expected the state to be error")
        }

        XCTAssertEqual(mock.saveCallCount, 0)
    }

    func testValidTitleCanBeSaved() async throws {
        let spy = SpyMemoryRepository()
        let viewModel = CreateMemoryViewModel(memoryRepository: spy)
        viewModel.title = "Test"

        await viewModel.save()

        XCTAssertEqual(spy.saveCallCount, 1)
        let savedMemory = try XCTUnwrap(spy.savedMemories.first)
        XCTAssertEqual(savedMemory.title, "Test")
        guard case .saved = viewModel.state else {
            return XCTFail("Expected the state to be saved")
        }
    }

    func testWhiteSpacesTitleCannotBeSaved() async throws {
        let spy = SpyMemoryRepository()
        let viewModel = CreateMemoryViewModel(memoryRepository: spy)
        viewModel.title = "  "

        await viewModel.save()

        XCTAssertEqual(spy.saveCallCount, 0)
    }

    func testCanSaveState() async throws {
        let spy = SpyMemoryRepository()
        let spy2 = SpyMemoryRepository()
        let viewModel = CreateMemoryViewModel(memoryRepository: spy)
        let viewModel2 = CreateMemoryViewModel(memoryRepository: spy2)
        viewModel.title = "Test"
        viewModel2.title = "  "

        XCTAssertEqual(viewModel.canSave, true)
        XCTAssertFalse(viewModel2.canSave)
    }

    func testSavedTitleIsTrimmed() async throws {
        let spy = SpyMemoryRepository()
        let viewModel = CreateMemoryViewModel(memoryRepository: spy)
        viewModel.title = "   Test  "

        await viewModel.save()

        let savedMemory = try XCTUnwrap(spy.savedMemories.first)
        XCTAssertEqual(savedMemory.title, "Test")
    }

    func testEmptyNotesBecomeNil() async throws {
        let spy = SpyMemoryRepository()
        let viewModel = CreateMemoryViewModel(memoryRepository: spy)
        viewModel.title = "Test"
        viewModel.note = "   "

        await viewModel.save()

        let savedMemory = try XCTUnwrap(spy.savedMemories.first)
        XCTAssertNil(savedMemory.note)
    }

    func testNonEmptyNotesAreSaved() async throws {
        let spy = SpyMemoryRepository()
        let viewModel = CreateMemoryViewModel(memoryRepository: spy)
        viewModel.title = "Test"
        viewModel.note = "  Note  "

        await viewModel.save()

        let savedMemory = try XCTUnwrap(spy.savedMemories.first)
        XCTAssertEqual(savedMemory.note, "Note")
    }

    func testSelectedMemoryDateIsPreserved() async throws {
        let spy = SpyMemoryRepository()
        let selectedDate = Date(timeIntervalSince1970: 1_000)
        let viewModel = CreateMemoryViewModel(memoryRepository: spy)
        viewModel.title = "Test"
        viewModel.memoryDate = selectedDate

        await viewModel.save()

        let savedMemory = try XCTUnwrap(spy.savedMemories.first)
        XCTAssertEqual(savedMemory.memoryDate, selectedDate)
    }

    func testInjectedUUIDAndDateAreUsed() async throws {
        let spy = SpyMemoryRepository()
        let expectedID = UUID()
        let expectedCreationDate = Date(timeIntervalSince1970: 2_000)

        let viewModel = CreateMemoryViewModel(
            memoryRepository: spy,
            idGenerator: { expectedID },
            dateProvider: { expectedCreationDate }
        )
        viewModel.title = "Test"

        await viewModel.save()

        let savedMemory = try XCTUnwrap(spy.savedMemories.first)
        XCTAssertEqual(savedMemory.id, expectedID)
        XCTAssertEqual(savedMemory.creationDate, expectedCreationDate)
    }

    func testRepositoryFailureSetsFailedStateAndRecordsAttempt() async {
        enum TestError: Error {
            case saveFailed
        }

        let spy = SpyMemoryRepository(saveError: TestError.saveFailed)
        let viewModel = CreateMemoryViewModel(memoryRepository: spy)
        viewModel.title = "Test"

        await viewModel.save()

        guard case .failed = viewModel.state else {
            return XCTFail("Expected failed state")
        }

        XCTAssertEqual(spy.saveCallCount, 1)
        XCTAssertTrue(spy.savedMemories.isEmpty)
    }

    func testSavingStateIsVisibleWhileSaving() async {
        let spy = SpyMemoryRepository()
        let viewModel = CreateMemoryViewModel(memoryRepository: spy)
        viewModel.title = "Test"
        var observedSaving = false

        spy.onSave = {
            if case .saving = viewModel.state {
                observedSaving = true
            }
        }

        await viewModel.save()

        XCTAssertTrue(observedSaving)
    }


}
