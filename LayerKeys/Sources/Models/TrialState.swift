import Foundation

struct TrialState: Codable, Equatable {
    let startedAt: Date

    func expiresAt(calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .day, value: AppConfig.trialLengthDays, to: startedAt) ?? startedAt
    }

    func isExpired(referenceDate: Date = .now, calendar: Calendar = .current) -> Bool {
        referenceDate >= expiresAt(calendar: calendar)
    }

    func remainingDays(referenceDate: Date = .now, calendar: Calendar = .current) -> Int {
        let expiry = expiresAt(calendar: calendar)
        guard expiry > referenceDate else { return 0 }

        let secondsLeft = expiry.timeIntervalSince(referenceDate)
        return max(1, Int(ceil(secondsLeft / 86_400)))
    }
}
