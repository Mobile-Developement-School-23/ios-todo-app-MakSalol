import UIKit


// MARK: - PrioritySegmentedControlDelegate

protocol PrioritySegmentedControlDelegate: AnyObject {
    @MainActor func didSelectPriority(_ importance: ImportanceType)
}

// MARK: - PrioritySegmentedControl

final class PrioritySegmentedControl: UIView {
    weak var delegate: PrioritySegmentedControlDelegate?

    private lazy var stackView = makeStackView()

    private lazy var controls = ImportanceType.allCases.map {
        let control = PriorityControl(importance: $0)
        control.addTarget(self, action: #selector(didTapControl), for: .touchUpInside)
        return control
    }

    var selectedPriority: ImportanceType = .common {
        didSet {
            guard selectedPriority != oldValue else {
                return
            }

            configureControls()
            delegate?.didSelectPriority(selectedPriority)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        nil
    }

    @objc
    private func didTapControl(_ sender: PriorityControl) {
        selectedPriority = sender.importance
    }

    private func setup() {

        addSubview(stackView)
        layer.cornerRadius = 8
        translatesAutoresizingMaskIntoConstraints = false

        configureControls()
        setupColors()
        setupConstraints()
    }

    private func configureControls() {
        controls.forEach {
            $0.isHiddenDivider = false
        }

        controls.forEach {
            $0.isSelected = ($0.importance == selectedPriority)
            $0.isHiddenDivider = ($0.importance == selectedPriority)
        }

        guard
            let index = ImportanceType.allCases.firstIndex(of: selectedPriority),
            index > 0
        else {
            return
        }

        controls[index - 1].isHiddenDivider = true
    }

    private func setupColors() {
        backgroundColor = AppColor.supportOverlay.color
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                stackView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2)
            ]
        )
    }

    private func makeStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: controls)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
}
