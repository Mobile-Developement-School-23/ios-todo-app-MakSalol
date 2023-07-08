import UIKit

final class DeleteControl: UIControl {
    override var intrinsicContentSize: CGSize {
        CGSize(width: super.intrinsicContentSize.width, height: 56)
    }

    private lazy var titleLabel = makeTitleLabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        nil
    }

    private func setup() {
        addSubview(titleLabel)

        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 16

        setupColors()
        setupConstraints()
    }

    private func setupColors() {
        backgroundColor = AppColor.backSecondary.color
        titleLabel.textColor = AppColor.colorRed.color
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
            ]
        )
    }

    private func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.body.font
        label.text = "Удалить"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
