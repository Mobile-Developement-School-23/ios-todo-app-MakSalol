import UIKit


protocol TodoItemDetailsViewControllerDelegate: AnyObject {
    @MainActor func itemsChanged()
}

// MARK: - TodoItemDetailsViewController

final class TodoItemDetailsViewController: UIViewController {

    private lazy var navBarContainerView = makeNavBarContainerView()
    private lazy var leftBarButton = makeBarButton(with: "Отменить")
    private lazy var titleLabel = makeTitleLabel()
    private lazy var rightBarButton = makeBarButton(with: "Сохранить")
    private lazy var scrollView = makeScrollView()
    private lazy var stackView = makeStackView()
    private lazy var textView = makeTextView()
    private lazy var detailsSecondaryView = makeDetailsSecondaryView()
    private lazy var deleteButton = makeDeleteButton()

    private var newText: String?
    private var selectedPriority: ImportanceType = .basic
    private var selectedDeadlineDate: Date?
    private var selectedColor: UIColor?

    private let item: TodoItem?
    private var detailsType: DetailsType
    private let fileCache = AppDelegate.shared().fileCache
    private let networkingService = AppDelegate.shared().networkingService

    weak var delegate: TodoItemDetailsViewControllerDelegate?

    init(item: TodoItem? = nil, detailsType: DetailsType = .new) {
        self.item = item
        self.detailsType = detailsType
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupKeyboard()
        setupObservers()
        setup()
        setupItemIfNeeded()
    }

    @objc
    private func keyboardWillShow(notification: NSNotification) {
        guard
            let userInfo = notification.userInfo,
            let nsValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else {
            return
        }

        let keyboardSize = nsValue.cgRectValue
        let contentInsets = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: keyboardSize.height,
            right: 0
        )
        scrollView.contentInset = contentInsets
    }

    @objc
    private func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        scrollView.contentInset = contentInsets
    }

    @objc
    private func didTapBarButton(sender: UIButton) {
        sender.isSelected.toggle()
        switch sender {
        case leftBarButton:
            dismiss(animated: true)
        case rightBarButton:
            let newItem: TodoItem
            if let item = item {
                newItem = TodoItem(id: item.id,
                                   text: newText ?? item.text,
                                   deadline: selectedDeadlineDate ?? item.deadline,
                                   importance: selectedPriority,
                                   taskCompleted: false,
                                   color: selectedColor?.hex ?? item.color)
                fileCache.Update(item: newItem)
            } else {
                newItem = TodoItem(text: newText ?? "",
                                   deadline: selectedDeadlineDate ?? item?.deadline,
                                   importance: selectedPriority,
                                   taskCompleted: false,
                                   color: selectedColor?.hex ?? item?.color)
                fileCache.Insert(item: newItem)
            }
            fileCache.addItem(item: newItem)
            //fileCache.saveToJSONFile(filename: "file")
            Task(priority: .high) {
                if detailsType == .change {
                    try await networkingService.updateItem(item: newItem)
                }
                else {
                    try await networkingService.postItem(item: newItem)
                }
            }

            delegate?.itemsChanged()
            dismiss(animated: true)
        default:
            break
        }
    }

    @objc
    private func didTapDeleteButton() {

        if let item = item {
            fileCache.removeItem(id: item.id)
            //fileCache.saveToJSONFile(filename: "file")
            fileCache.Delete(item: item)
            Task(priority: .high) {
               try await networkingService.deleteItem(id: item.id)
            }
            delegate?.itemsChanged()
        }
        dismiss(animated: true)

    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func setup() {
        [
            navBarContainerView,
            scrollView
        ].forEach { view.addSubview($0) }

        view.keyboardLayoutGuide.followsUndockedKeyboard = true

        setupColors()
        setupConstraints()
    }

    private func setupColors() {
        view.backgroundColor = AppColor.backPrimary.color
        textView.backgroundColor = AppColor.backSecondary.color
        titleLabel.textColor = AppColor.labelPrimary.color
        [leftBarButton, rightBarButton].forEach {
            $0.setTitleColor(AppColor.colorBlue.color, for: .normal)
        }
        rightBarButton.setTitleColor(AppColor.labelTertiary.color, for: .disabled)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                navBarContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                navBarContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                navBarContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                navBarContainerView.heightAnchor.constraint(equalToConstant: 56)
            ]
        )
        NSLayoutConstraint.activate(
            [
                leftBarButton.centerYAnchor.constraint(equalTo: navBarContainerView.centerYAnchor),
                leftBarButton.leadingAnchor.constraint(
                    equalTo: navBarContainerView.leadingAnchor,
                    constant: 16
                )
            ]
        )
        NSLayoutConstraint.activate(
            [
                titleLabel.centerXAnchor.constraint(equalTo: navBarContainerView.centerXAnchor),
                titleLabel.centerYAnchor.constraint(equalTo: navBarContainerView.centerYAnchor)
            ]
        )
        NSLayoutConstraint.activate(
            [
                rightBarButton.centerYAnchor.constraint(equalTo: navBarContainerView.centerYAnchor),
                rightBarButton.trailingAnchor.constraint(
                    equalTo: navBarContainerView.trailingAnchor,
                    constant: -16
                )
            ]
        )
        NSLayoutConstraint.activate(
            [
                scrollView.topAnchor.constraint(equalTo: navBarContainerView.bottomAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ]
        )
        NSLayoutConstraint.activate(
            [
                stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
                stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
                stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
            ]
        )
        NSLayoutConstraint.activate(
            [
                textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120)
            ]
        )
    }

    private func setupItemIfNeeded() {
        guard let item else {
            textView.text = "Что надо сделать?"
            textView.textColor = AppColor.labelTertiary.color
            return
        }

        textView.text = item.text

    }

    private func makeNavBarContainerView() -> UIView {
        let view = UIView()
        [
            leftBarButton,
            titleLabel,
            rightBarButton
        ].forEach { view.addSubview($0) }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func makeBarButton(with title: String) -> UIButton {
        let button = UIButton()
        button.addTarget(self, action: #selector(didTapBarButton), for: .touchUpInside)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = AppFont.body.font
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.body.font
        label.textAlignment = .center
        label.text = "Дело"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private func makeScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.addSubview(stackView)
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }

    private func makeStackView() -> UIStackView {
        let stackView = UIStackView(
            arrangedSubviews: [
                textView,
                detailsSecondaryView,
                deleteButton
            ]
        )
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    private func makeTextView() -> UITextView {
        let textView = UITextView()
        textView.font = AppFont.body.font
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.layer.cornerRadius = 16
        textView.textColor = AppColor.labelPrimary.color
        textView.textContainerInset = UIEdgeInsets(
            top: 16,
            left: 16,
            bottom: 16,
            right: 16
        )
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }

    private func makeDetailsSecondaryView() -> UIView {
        let view = TodoItemDetailsView(item: item)
        view.delegate = self
        return view
    }

    private func makeDeleteButton() -> UIControl {
        let button = DeleteControl()
        button.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
        return button
    }
}

// MARK: - TodoItemDetailsViewDelegate: UITextViewDelegate

extension TodoItemDetailsViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        newText = textView.text

        if textView.text.isEmpty {
            textView.text = "Что надо сделать?"
            textView.textColor = AppColor.labelTertiary.color
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {

        if textView.text.isEmpty {
            textView.text = "Что надо сделать?"
            textView.textColor = AppColor.labelTertiary.color
        }

        if textView.textColor == AppColor.labelTertiary.color {
            textView.text = ""
            textView.textColor = AppColor.labelPrimary.color
        }
    }
}

// MARK: - TodoItemDetailsViewDelegate

extension TodoItemDetailsViewController: TodoItemDetailsViewDelegate {
    func didSelectPriority(_ importance: ImportanceType) {
        selectedPriority = importance
    }

    func didSelectDeadline(_ date: Date?) {
        selectedDeadlineDate = date
    }

    func didSelectColor(_ color: UIColor?) {
        selectedColor = color
    }
}
