import UIKit

enum AppFont {
    case largeTitle
    case title
    case headline
    case body
    case subhead
    case footnote
}

extension AppFont {
    var font: UIFont {
        var font: UIFont?

        switch self {
        case .largeTitle:
            font = UIFont(
                name: "SFProDisplay-Regular",
                size: 38
            )?.withWeight(UIFont.Weight(rawValue: 700))
        case .title:
            font = UIFont(
                name: "SFProDisplay-Regular",
                size: 20
            )?.withWeight(UIFont.Weight(600))
        case .headline:
            font = UIFont(
                name: "SFProText-Regular",
                size: 17
            )?.withWeight(UIFont.Weight(600))
        case .body:
            font = UIFont(
                name: "SFProText-Regular",
                size: 17
            )?.withWeight(UIFont.Weight(400))
        case .subhead:
            font = UIFont(
                name: "SFProText-Regular",
                size: 15
            )?.withWeight(UIFont.Weight(400))
        case .footnote:
            font = UIFont(
                name: "SFProText-Regular",
                size: 13
            )?.withWeight(UIFont.Weight(600))
        }

        return font ?? UIFont()
    }
}
