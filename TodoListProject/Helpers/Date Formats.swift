import Foundation

struct DateFormats {
    let dateFormatter = DateFormatter()

    init() {
        dateFormatter.dateFormat = "d MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "ru_RU")
    }
}
