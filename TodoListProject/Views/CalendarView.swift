import UIKit

// MARK: - CalendarViewDelegate

protocol CalendarViewDelegate: AnyObject {
    func calendarView(_ view: CalendarView, didChange date: Date)
}

// MARK: - CalendarView

final class CalendarView: UIView {
    weak var delegate: CalendarViewDelegate?

    var selectedDate: Date? {
        didSet {
            guard let selectedDate else {
                return
            }

            let components = makeDateComponents(from: selectedDate)
            calendarSelectionBehavior.selectedDate = components
            calendarView.selectionBehavior = calendarSelectionBehavior
        }
    }

    private(set) lazy var calendarSelectionBehavior = UICalendarSelectionSingleDate(delegate: self)
    private(set) lazy var calendarView = makeCalendarView()
    private lazy var dividerView = DividerView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        nil
    }

    private func setup() {
        [calendarView, dividerView].forEach { addSubview($0) }

        translatesAutoresizingMaskIntoConstraints = false

        setupColors()
        setupConstraints()
    }

    private func setupColors() {
        backgroundColor = AppColor.backSecondary.color
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                calendarView.centerXAnchor.constraint(equalTo: centerXAnchor),
                calendarView.topAnchor.constraint(
                    equalTo: topAnchor,
                    constant: 8
                ),
                calendarView.leadingAnchor.constraint(
                    greaterThanOrEqualTo: leadingAnchor,
                    constant: 16
                ),
                calendarView.trailingAnchor.constraint(
                    lessThanOrEqualTo: trailingAnchor,
                    constant: -16
                ),
                calendarView.bottomAnchor.constraint(
                    equalTo: bottomAnchor,
                    constant: -8
                )
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

    private func makeCalendarView() -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.calendar = CalendarProvider.calendar
        return calendarView
    }

    private func makeDateComponents(from date: Date) -> DateComponents {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents(
            [.year, .month, .day],
            from: date
        )
        return dateComponents
    }
}

// MARK: - UICalendarSelectionSingleDateDelegate

extension CalendarView: UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard
            let dateComponents,
            let date = dateComponents.date
        else {
            return
        }

        delegate?.calendarView(self, didChange: date)
    }
}
