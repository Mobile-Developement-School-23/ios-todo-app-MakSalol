import Foundation
import UIKit

protocol CustomHeaderViewDelegate: AnyObject {
    func buttonTapped(_ sender: UIButton)
}

final class CustomHeaderView: UIView {

    static let reuseId = "customHeader"
    weak var delegate: CustomHeaderViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: frame.width, height: 40))
        self.backgroundColor = AppColor.backPrimary.color
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Выполнено – 0"
        label.font = AppFont.subhead.font
        label.textColor = AppColor.labelTertiary.color
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var showButton: UIButton = {
        let button = UIButton()
        button.setTitle("Показать", for: .normal)
        button.titleLabel?.font = AppFont.subhead.font
        button.titleLabel?.textAlignment = .right
        button.setTitleColor(AppColor.colorBlue.color, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()

    func setupConstraints() {
        addSubview(subtitleLabel)
        addSubview(showButton)

        NSLayoutConstraint.activate([
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])

        NSLayoutConstraint.activate([
            showButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            showButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            showButton.widthAnchor.constraint(lessThanOrEqualToConstant: 100)
        ])
    }

    @objc
    private func buttonTapped(_ sender: UIButton) {
        delegate?.buttonTapped(sender)
    }

}
