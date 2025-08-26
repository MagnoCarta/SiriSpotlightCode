import XCTest
import CoreSpotlight
@testable import SiriSpotlight

final class DeepLinkTests: XCTestCase {
    func testActivityRoutesToTask() {
        let task = TaskEntity(id: UUID(), title: "Pay bills", status: .inProgress)
        TaskStore.shared.tasks = [task]
        let activity = NSUserActivity(activityType: "com.example.task.detail")
        activity.userInfo = ["id": task.id.uuidString]

        let resolved = Router.task(from: activity)
        XCTAssertEqual(resolved?.id, task.id)
    }
}
