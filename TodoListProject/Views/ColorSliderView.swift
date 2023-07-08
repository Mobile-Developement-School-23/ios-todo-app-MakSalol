import UIKit

// MARK: - ColorSliderViewDelegate

protocol ColorSliderViewDelegate: AnyObject {
    @MainActor func colorSliderView(_ view: ColorSliderView, didChange value: Int)
}

// MARK: - ColorSliderView

final class ColorSliderView: UIView {
    enum Color {
        case red
        case green
        case blue
    }

    weak var delegate: ColorSliderViewDelegate?

    var value: Int = 0 {
        didSet {
            configureSubviews(for: value)
            delegate?.colorSliderView(self, didChange: value)
        }
    }

    private lazy var slider = makeSlider()
    private lazy var textFieldContainerView = makeTextFieldContainerView()
    private lazy var textField = makeTextField()

    private(set) var color: Color

    init(color: Color) {
        self.color = color
        super.init(frame: .zero)

        setup()
    }

    required init?(coder: NSCoder) {
        nil
    }

    func setValue(_ value: Int) {
        configureSubviews(for: value)
    }

    @objc
    private func didChangeSlider(_ slider: UISlider) {
        value = Int(slider.value)
    }

    private func configureSubviews(for value: Int) {
        slider.value = Float(value)
        textField.text = value.description
    }

    private func setup() {
        [slider, textFieldContainerView].forEach { addSubview($0) }

        translatesAutoresizingMaskIntoConstraints = false

        configureSubviews(for: value)
        setupColors()
        setupConstraints()
    }

    private func setupColors() {
        textFieldContainerView.backgroundColor = AppColor.supportOverlay.color
        textField.textColor = AppColor.labelPrimary.color

        switch color {
        case .red:
            slider.tintColor = AppColor.colorRed.color
        case .green:
            slider.tintColor = AppColor.colorGreen.color
        case .blue:
            slider.tintColor = AppColor.colorBlue.color
        }
        slider.maximumTrackTintColor = AppColor.supportOverlay.color
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                slider.centerYAnchor.constraint(equalTo: centerYAnchor),
                slider.leadingAnchor.constraint(equalTo: leadingAnchor),
                slider.heightAnchor.constraint(equalToConstant: 32)
            ]
        )
        NSLayoutConstraint.activate(
            [
                textFieldContainerView.topAnchor.constraint(equalTo: topAnchor),
                textFieldContainerView.leadingAnchor.constraint(
                    equalTo: slider.trailingAnchor,
                    constant: 16
                ),
                textFieldContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
                textFieldContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
                textFieldContainerView.heightAnchor.constraint(equalToConstant: 32),
                textFieldContainerView.widthAnchor.constraint(equalToConstant: 48)
            ]
        )

        NSLayoutConstraint.activate(
            [
                textField.topAnchor.constraint(
                    equalTo: textFieldContainerView.topAnchor,
                    constant: 4
                ),
                textField.leadingAnchor.constraint(
                    equalTo: textFieldContainerView.leadingAnchor,
                    constant: 8
                ),
                textField.trailingAnchor.constraint(
                    equalTo: textFieldContainerView.trailingAnchor,
                    constant: -8
                ),
                textField.bottomAnchor.constraint(
                    equalTo: textFieldContainerView.bottomAnchor,
                    constant: -4
                )
            ]
        )
    }

    private func makeSlider() -> UISlider {
        let slider = UISlider()
        slider.addTarget(self, action: #selector(didChangeSlider), for: .valueChanged)
        slider.maximumValue = 255
        slider.minimumValue = 0
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.isContinuous = true
        return slider
    }

    private func makeTextFieldContainerView() -> UIView {
        let view = UIView()
        view.addSubview(textField)
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func makeTextField() -> UITextField {
        let textField = UITextField()
        textField.delegate = self
        textField.font = AppFont.body.font
        textField.keyboardType = .numberPad
        textField.text = "0"
        textField.textAlignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
}

// MARK: - UITextFieldDelegate

extension ColorSliderView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else {
            return
        }

        let selectedValue = Int(text) ?? 0
        value = selectedValue >= 255 ? 255 : selectedValue
        textField.text = value.description
    }
}
