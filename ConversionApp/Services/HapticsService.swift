import Foundation
import UIKit

class HapticsService {
    func selectionChanged(enabled: Bool) {
        guard enabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    func success(enabled: Bool) {
        guard enabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
}
