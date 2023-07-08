import UIKit


final class PriorityControl: UIControl {
    var isHiddenDivider = false {
        didSet {
            guard
                let dividerView,
                isHiddenDivider != oldValue
            else {
                return
            }

            dividerView.isHidden = isHiddenDivider
        }
    }

    private lazy var contentView = makeContentView()
    private lazy var dividerView = makeDivierView()

    override var intrinsicContentSize: CGSize {
        return CGSize(width: 48, height: 32)
    }

    override var isSelected: Bool {
        didSet {
            guard isSelected != oldValue else {
                return
            }

            backgroundColor = isSelected ? AppColor.backElevated.color : .clear
        }
    }

    private(set) var importance: ImportanceType

    init(importance: ImportanceType) {
        self.importance = importance
        super.init(frame: .zero)

        setup()
    }

    required init?(coder: NSCoder) {
        nil
    }

    private func setup() {
        addSubview(contentView)
        if let dividerView {
            addSubview(dividerView)
        }

        layer.cornerRadius = 8
        translatesAutoresizingMaskIntoConstraints = false

        setupColors()
        setupConstraints()
    }

    private func setupColors() {
        backgroundColor = .clear
        if let dividerView {
            dividerView.backgroundColor = AppColor.supportSeparator.color
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
                contentView.centerYAnchor.constraint(equalTo: centerYAnchor)
            ]
        )
        if let dividerView {
            NSLayoutConstraint.activate(
                [
                    dividerView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
                    dividerView.trailingAnchor.constraint(equalTo: trailingAnchor),
                    dividerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
                    dividerView.widthAnchor.constraint(equalToConstant: 0.25)
                ]
            )
        }
    }

    private func makeContentView() -> UIView {
        switch importance {
        case .unimportant:
            let imageView = UIImageView(image: AppImage.priorityLow.image)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        case .common:
            let label = UILabel()
            label.font = AppFont.subhead.font
            label.textColor = AppColor.labelPrimary.color
            label.text = "нет"
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        case .important:
            let imageView = UIImageView(image: AppImage.priorityHigh.image)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }
    }

    private func makeDivierView() -> UIView? {
        guard importance != ImportanceType.allCases.last else {
            return nil
        }

        return DividerView()
    }
}
