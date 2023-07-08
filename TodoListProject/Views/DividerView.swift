import UIKit

final class DividerView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = AppColor.supportSeparator.color
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        nil
    }
}
