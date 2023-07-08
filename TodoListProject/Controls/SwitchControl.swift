import UIKit

final class SwitchControl: UIControl {
    override var isSelected: Bool {
        didSet {
            configureSubviews()
        }
    }

    var title: String? {
        didSet {
            guard let title, title != oldValue else {
                return
            }

            titleLabel.text = title
        }
    }

    var subtitleColor: UIColor? {
        didSet {
            guard let subtitleColor, subtitleColor != oldValue else {
                return
            }

            subtitleLabel.textColor = subtitleColor
        }
    }

    var subtitle: String? {
        didSet {
            guard let subtitle, subtitle != oldValue else {
                return
            }

            subtitleLabel.text = subtitle
        }
    }

    var isHiddenDividerByDefault: Bool? {
        didSet {
            guard let isHiddenDividerByDefault, isHiddenDividerByDefault != oldValue else {
                return
            }

            dividerView.isHidden = isHiddenDividerByDefault
        }
    }

    private lazy var stackView = makeVerticalStackView()
    private lazy var titleLabel = makeTitleLabel()
    private lazy var subtitleLabel = makeSubtitleLabel()
    private lazy var switchControl = makeSwitch()
    private lazy var dividerView = DividerView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        nil
    }

    private func configureSubviews() {
        subtitleLabel.isHidden = !isSelected
        switchControl.isOn = isSelected
        switchControl.tintColor = isSelected
            ? AppColor.colorGreen.color
            : AppColor.supportOverlay.color
        if isHiddenDividerByDefault == nil {
            dividerView.isHidden = !isSelected
        }
    }

    private func setup() {
        [
            stackView,
            switchControl,
            dividerView
        ].forEach { addSubview($0) }

        translatesAutoresizingMaskIntoConstraints = false

        configureSubviews()
        setupColors()
        setupConstraints()
    }

    private func setupColors() {
        titleLabel.textColor = AppColor.labelPrimary.color
        subtitleLabel.textColor = AppColor.colorBlue.color
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16)
            ]
        )
        NSLayoutConstraint.activate(
            [
                switchControl.topAnchor.constraint(equalTo: topAnchor, constant: 12),
                switchControl.leadingAnchor.constraint(
                    greaterThanOrEqualTo: stackView.trailingAnchor,
                    constant: 16
                ),
                switchControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
                switchControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
                switchControl.heightAnchor.constraint(equalToConstant: 32),
                switchControl.widthAnchor.constraint(equalToConstant: 52)
            ]
        )
        NSLayoutConstraint.activate(
            [
                dividerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                dividerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                dividerView.bottomAnchor.constraint(equalTo: bottomAnchor),
                dividerView.heightAnchor.constraint(equalToConstant: 0.5)
            ]
        )
    }

    private func makeVerticalStackView() -> UIStackView {
        let stackView = UIStackView(
            arrangedSubviews: [titleLabel, subtitleLabel]
        )
        stackView.axis = .vertical
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    private func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.body.font
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func makeSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.footnote.font
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func makeSwitch() -> UISwitch {
        let switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.isUserInteractionEnabled = false
        return switchControl
    }
}
