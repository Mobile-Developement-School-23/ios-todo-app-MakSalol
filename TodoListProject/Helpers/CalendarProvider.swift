import Foundation

final class CalendarProvider {
    static var calendar: Calendar {
        var calendar = Calendar(identifier: .iso8601)
        calendar.locale = Locale(identifier: "ru")
        return calendar
    }
}
