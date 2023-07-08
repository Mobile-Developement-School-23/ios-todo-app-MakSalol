import UIKit


// MARK: - TodoItemDetailsViewDelegate

protocol TodoItemDetailsViewDelegate: AnyObject {
    @MainActor func didSelectPriority(_ priority: ImportanceType)
    @MainActor func didSelectDeadline(_ date: Date?)
    @MainActor func didSelectColor(_ color: UIColor?)
}

// MARK: - TodoItemDetailsView

final class TodoItemDetailsView: UIView {
    weak var delegate: TodoItemDetailsViewDelegate?

    private lazy var stackView = makeStackView()
    private lazy var priorityView = makePriorityView()
    private lazy var deadlineControl = makeDeadlineSwitchControl()
    private lazy var calendarView = makeCalendarView()
    private lazy var colorSwitchControl = makeColorSwitchControl()
    private lazy var colorPickerView = makeColorPickerView()

    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "ru")
        return dateFormatter
    }

    private var deadlineFallback: Date {
        return CalendarProvider.calendar.date(
            byAdding: .day,
            value: 1,
            to: Date()
        ) ?? Date()
    }

    private var colorFallback: UIColor {
        return AppColor.colorBlue.color
    }

    private let item: TodoItem?

    init(item: TodoItem?) {
        self.item = item
        super.init(frame: .zero)

        setup()
    }

    required init?(coder: NSCoder) {
        nil
    }

    @objc
    private func didTapDeadlineControl(_ sender: SwitchControl) {
        sender.isSelected.toggle()
        deadlineControl.subtitle = sender.isSelected ? dateFormatter.string(from: deadlineFallback) : nil
        calendarView.selectedDate = sender.isSelected ? deadlineFallback : nil

        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.calendarView.isHidden = !sender.isSelected
        }

        delegate?.didSelectDeadline(sender.isSelected ? deadlineFallback : nil)
    }

    @objc
    private func didTapColorControl(_ sender: SwitchControl) {
        sender.isSelected.toggle()
        colorSwitchControl.subtitleColor = colorFallback
        colorPickerView.setColor(colorFallback)

        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.colorPickerView.isHidden = !sender.isSelected
        }

        delegate?.didSelectColor(sender.isSelected ? colorFallback : nil)
    }

    private func setup() {
        addSubview(stackView)

        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 16

        if item?.color != nil {
            colorSwitchControl.isSelected = true
            colorSwitchControl.subtitleColor = UIColor(hex: (item?.color)!)
        }

        if let deadline = item?.deadline {
            deadlineControl.subtitle = dateFormatter.string(from: deadline)
            deadlineControl.isSelected = true
        }

        setupColors()
        setupConstraints()
    }

    private func setupColors() {
        backgroundColor = AppColor.backSecondary.color
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                stackView.topAnchor.constraint(equalTo: topAnchor),
                stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
                stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ]
        )
    }

    private func makeStackView() -> UIStackView {
        let stackView = UIStackView(
            arrangedSubviews: [
                priorityView,
                deadlineControl,
                calendarView,
                colorSwitchControl,
                colorPickerView
            ]
        )
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    private func makePriorityView() -> UIView {
        let view = PriorityPickerView(importance: item?.importance ?? ImportanceType.basic)
        view.delegate = self
        return view
    }

    private func makeDeadlineSwitchControl() -> SwitchControl {
        let control = SwitchControl()
        control.addTarget(self, action: #selector(didTapDeadlineControl), for: .touchUpInside)
        control.isHiddenDividerByDefault = false
        control.title = "Сделать до"
        return control
    }

    private func makeCalendarView() -> CalendarView {
        let view = CalendarView()
        view.delegate = self
        view.isHidden = true
        return view
    }

    private func makeColorSwitchControl() -> SwitchControl {
        let control = SwitchControl()
        control.addTarget(self, action: #selector(didTapColorControl), for: .touchUpInside)
        control.title = "Цвет"
        control.subtitle = "цвет текста"
        return control
    }

    private func makeColorPickerView() -> ColorPickerView {
        let colorPicker = ColorPickerView()
        colorPicker.delegate = self
        colorPicker.isHidden = true
        colorPicker.setColor(AppColor.colorRed.color)
        return colorPicker
    }
}

// MARK: - PriorityPickerViewDelegate

extension TodoItemDetailsView: PriorityPickerViewDelegate {
    func didSelectPriority(_ importance: ImportanceType) {
        delegate?.didSelectPriority(importance)
    }
}

// MARK: - CalendarViewDelegate

extension TodoItemDetailsView: CalendarViewDelegate {
    func calendarView(_ view: CalendarView, didChange date: Date) {
        deadlineControl.subtitle = dateFormatter.string(from: date)
        delegate?.didSelectDeadline(date)
    }
}

// MARK: - ColorPickerViewDelegate

extension TodoItemDetailsView: ColorPickerViewDelegate {
    func colorPickerView(_ view: ColorPickerView, didChangeColor color: UIColor?) {
        guard let color else {
            return
        }

        colorSwitchControl.subtitleColor = color
        delegate?.didSelectColor(color)
    }
}
