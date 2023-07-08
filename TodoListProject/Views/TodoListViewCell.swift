import Foundation
import UIKit


final class TodoListViewSell: UITableViewCell {

    static let reuseId = "TodoListViewSell"

    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM"
        dateFormatter.locale = Locale(identifier: "ru")
        return dateFormatter
    }

    private var bodyLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = AppFont.body.font
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.sizeToFit()
        return label
    }()

    private var doneImage: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 12
        image.image = AppImage.radioButtonOff.image
        image.backgroundColor = AppColor.colorWhite.color
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    private var deadlineLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = AppFont.subhead.font
        label.textColor = AppColor.labelTertiary.color
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var priorityImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    private var chevronImage: UIImageView = {
        let image = UIImageView(image: AppImage.chevron.image)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    private lazy var labelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
                bodyLabel,
                deadlineLabel
        ])

        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            doneImage,
            priorityImage,
            labelStackView
        ])

        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubview(doneImage)
        addSubview(priorityImage)
        addSubview(labelStackView)
        addSubview(chevronImage)
        labelStackView.addSubview(bodyLabel)
        labelStackView.addSubview(deadlineLabel)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCell(item: TodoItem) {
        bodyLabel.text = item.text
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: item.text)

        let image = UIImage(systemName: "calendar")!
        let imageAttachment = NSTextAttachment(image: image)
        imageAttachment.bounds = CGRect(x: 0, y: -4.0, width: imageAttachment.image?.size.width ?? 0, height: imageAttachment.image?.size.height ?? 0)
        let imageString = NSAttributedString(attachment: imageAttachment)

        let value: Int

        if item.taskCompleted {
            value = 1
            bodyLabel.textColor = AppColor.labelTertiary.color
            doneImage.image = UIImage(named: "radio_button_on_24x24")
        } else {
            value = 0
            bodyLabel.textColor = AppColor.labelPrimary.color
            doneImage.image = UIImage(named: "radio_button_off_24x24")

            if let color = item.color {
                bodyLabel.textColor = UIColor(hex: color)
            }
        }

        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: value, range: NSRange(location: 0, length: attributeString.length))
        bodyLabel.attributedText = attributeString

        switch item.importance {
        case .important:
            if !item.taskCompleted {
                doneImage.image = UIImage(named: "radio_button_high_priority_24x24")
            }
            priorityImage.image = AppImage.priorityHigh.image
        case .low:
            priorityImage.image = AppImage.priorityLow.image
        case .basic:
            priorityImage.image = nil
        }

        if let deadline = item.deadline {
            let dealineAttributeString = NSMutableAttributedString(string: dateFormatter.string(from: deadline))
            let completeString = NSMutableAttributedString(string: "")
            let spaceString = NSMutableAttributedString(string: " ")
            completeString.append(imageString)
            completeString.append(spaceString)
            completeString.append(dealineAttributeString)
            deadlineLabel.attributedText = completeString
        } else {
            deadlineLabel.attributedText = nil
        }

    }

    private func setupConstraints() {

        NSLayoutConstraint.activate([
            doneImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            doneImage.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            priorityImage.leadingAnchor.constraint(equalTo: doneImage.trailingAnchor, constant: 12),
            priorityImage.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            labelStackView.leadingAnchor.constraint(equalTo: priorityImage.trailingAnchor, constant: 2),
            labelStackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            labelStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            labelStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            labelStackView.trailingAnchor.constraint(lessThanOrEqualTo: chevronImage.leadingAnchor, constant: -16),
            bodyLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 80)
        ])

        NSLayoutConstraint.activate([
            chevronImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            chevronImage.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
