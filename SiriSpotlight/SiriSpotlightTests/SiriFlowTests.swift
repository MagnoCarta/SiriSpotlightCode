import XCTest
@testable import SiriSpotlight

final class SiriFlowTests: XCTestCase {
    func testVoiceCreatesTask() async throws {
        TaskStore.shared.tasks = []
        let intent = CreateTaskIntent(title: "Walk dog")
        _ = try await intent.perform()
        XCTAssertEqual(TaskStore.shared.tasks.first?.title, "Walk dog")
    }
}
