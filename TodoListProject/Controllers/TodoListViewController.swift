import UIKit

enum DetailsType {
    case new
    case change
}

final class TodoListViewController: UIViewController {
    let fileCache = AppDelegate.shared().fileCache
    let networkingService = AppDelegate.shared().networkingService
    private let headerView = CustomHeaderView()
    private var displayedTasks = [TodoItem]()
    private var isDirty = true

    private func setupDisplayedTasks() {
        displayedTasks = displayingAllTasks() ? fileCache.todoItems.sorted { $0.taskCompleted.intValue > $1.taskCompleted.intValue } : fileCache.todoItems.filter { $0.taskCompleted == false }
        setupCompletedTasksCount()
    }

    private var completedTasks = 0
    private var showCompleted = false

    private func displayingAllTasks() -> Bool {
        return headerView.showButton.titleLabel?.text == "Cкрыть"
    }

    private func setupCompletedTasksCount() {
        let completed = fileCache.todoItems.filter { $0.taskCompleted == true }.count
        completedTasks = completed
        headerView.subtitleLabel.text = "Выполнено – \(completedTasks)"
    }

    private func fetchDataFromNetwork() {
        Task(priority: .high) {
            do {
                let items = try await networkingService.getList()
                isDirty = false
                fetchDataToLocal(items: items)
            }
            catch {
                isDirty = true
            }
        }
    }
    
    @MainActor
    func fetchDataToLocal(items: [TodoItem]) {
        fileCache.todoItems = items
        fileCache.saveToJSONFile(filename: "file")
        setupDisplayedTasks()
        setupCompletedTasksCount()
        UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.tableView.reloadData()
        }, completion: nil)
    }
    
    private let tableView: UITableView = {
        let tblView = UITableView(frame: .zero, style: .insetGrouped)
        tblView.layer.cornerRadius = 16
        tblView.translatesAutoresizingMaskIntoConstraints = false
        tblView.showsVerticalScrollIndicator = false
        tblView.estimatedRowHeight = 60
        tblView.rowHeight = UITableView.automaticDimension
        return tblView
    }()

    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
        button.setImage(AppImage.addLarge.image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDataFromNetwork()
        tableView.dataSource = self
        tableView.delegate = self
        headerView.delegate = self
        tableView.register(TodoListViewSell.self, forCellReuseIdentifier: TodoListViewSell.reuseId)
        setup()
    }

    @objc
    private func didTapAddButton(_ sender: UIButton) {
        let itemDetailsVC = TodoItemDetailsViewController()
        itemDetailsVC.delegate = self
        present(
            itemDetailsVC,
            animated: true
        )
    }

    @objc
    private func presentDetailsVC(at index: Int) {
        let item = displayedTasks[index]
        let itemDetailsVC = TodoItemDetailsViewController(item: item, detailsType: .change)
        itemDetailsVC.delegate = self
        present(itemDetailsVC, animated: true)
    }

    private func setup() {
        self.title = "Мои дела"
        view.addSubview(tableView)
        view.addSubview(addButton)
        setupColors()
        setupConstraints()
        setupCompletedTasksCount()
    }

    private func setupColors() {
        view.backgroundColor = AppColor.backPrimary.color
        tableView.backgroundColor = .clear
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                addButton.bottomAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                    constant: -20
                )
            ]
        )

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

    }

    private func delete(rowIndexPathAt indexPath: IndexPath) -> UIContextualAction {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) {[weak self] (_, _, completion) in
            guard let self = self else {return}
            let item = displayedTasks[indexPath.row]
            displayedTasks.remove(at: indexPath.row)
            self.fileCache.removeItem(id: item.id)
            self.fileCache.saveToJSONFile(filename: "file")
            Task(priority: .userInitiated) {
                if self.isDirty {
                    self.fetchDataFromNetwork()
                }
                do {
                    try await self.networkingService.deleteItem(id: item.id)
                    self.isDirty = false
                }
                catch {
                    self.isDirty = true
                }
            }
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        deleteAction.backgroundColor = AppColor.colorRed.color
        deleteAction.image = UIImage(systemName: "trash")
        return deleteAction
    }

    private func edit(rowIndexPathAt indexPath: IndexPath) -> UIContextualAction {
        let editAction = UIContextualAction(style: .destructive, title: nil) {[weak self] (_, _, completion) in
            guard let self = self else {return}
            self.presentDetailsVC(at: indexPath.row)
            completion(true)
        }
        editAction.backgroundColor = AppColor.colorGrayLight.color
        editAction.image = UIImage(systemName: "info.circle.fill")
        return editAction
    }

    private func complete(rowIndexPathAt indexPath: IndexPath) -> UIContextualAction {
        let completeAction = UIContextualAction(style: .destructive, title: nil) {[weak self] (_, _, completion) in
            guard let self = self else {return}
            var item = displayedTasks[indexPath.row]
            displayedTasks.remove(at: indexPath.row)
            item.taskCompleted = true
            self.fileCache.addItem(item: item)
            self.fileCache.saveToJSONFile(filename: "file")
            Task(priority: .userInitiated) {
                if self.isDirty {
                    self.fetchDataFromNetwork()
                }
                do {
                    try await self.networkingService.updateItem(item: item)
                    self.isDirty = false
                }
                catch {
                    self.isDirty = true
                }
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            setupCompletedTasksCount()
            completion(true)
        }
        completeAction.backgroundColor = AppColor.colorGreen.color
        completeAction.image = UIImage(systemName: "checkmark.circle.fill")
        return completeAction
    }
}

extension TodoListViewController: TodoItemDetailsViewControllerDelegate {
    func itemsChanged() {
        setupDisplayedTasks()
        tableView.reloadData()
        setupCompletedTasksCount()
    }
}

extension TodoListViewController: CustomHeaderViewDelegate {
    func buttonTapped(_ sender: UIButton) {
        if displayingAllTasks() {
            sender.setTitle("Показать", for: .normal)
        } else {
            sender.setTitle("Cкрыть", for: .normal)
        }
        UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.setupDisplayedTasks()
            self.tableView.reloadData()
        }, completion: nil)
        setupCompletedTasksCount()
    }
}

extension TodoListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedTasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TodoListViewSell.reuseId, for: indexPath) as! TodoListViewSell
        cell.setupCell(item: displayedTasks[indexPath.row])
        return cell
    }

    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

       var maskPath = UIBezierPath(
         roundedRect: cell.bounds,
         byRoundingCorners: [.topLeft, .topRight],
         cornerRadii: CGSize(width: 0, height: 0)
       )

       if indexPath.row == 0 {
         maskPath = UIBezierPath(
           roundedRect: cell.bounds,
           byRoundingCorners: [.topLeft, .topRight],
           cornerRadii: CGSize(width: 16, height: 16)
         )
       }

       if indexPath.row == displayedTasks.count - 1 {
         maskPath = UIBezierPath(
           roundedRect: cell.bounds,
           byRoundingCorners: [.bottomLeft, .bottomRight],
           cornerRadii: CGSize(width: 16, height: 16)
         )
       }

       let shape = CAShapeLayer()
       shape.path = maskPath.cgPath
       cell.layer.mask = shape
     }

}

extension TodoListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presentDetailsVC(at: indexPath.row)
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let completeAction = complete(rowIndexPathAt: indexPath)
        return UISwipeActionsConfiguration(actions: [completeAction])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = delete(rowIndexPathAt: indexPath)
        let editAction = edit(rowIndexPathAt: indexPath)
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

        let identifier = "\(indexPath.row)" as NSString

        return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { _ in

            let detailsAction = UIAction(title: "Подробности") {[weak self] _ in
                guard let self = self else {return}
                self.presentDetailsVC(at: indexPath.row)
            }
            return UIMenu(children: [detailsAction])
        }
    }

    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {

        guard
            let identifier = configuration.identifier as? String,
            let index = Int(identifier)
            else {
              return
          }

        animator.addCompletion {
            self.presentDetailsVC(at: index)
        }
    }
}
