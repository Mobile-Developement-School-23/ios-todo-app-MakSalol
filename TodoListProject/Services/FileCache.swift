import Foundation
import SQLite
import CoreData

enum Storage {
    case coreData
    case SQL
}

enum SQLModel {
    static let id = Expression<String>("id")
    static let text = Expression<String>("text")
    static let importance = Expression<String>("importance")
    static let deadline = Expression<Int64?>("deadline")
    static let taskCompleted = Expression<Bool>("taskCompleted")
    static let taskChanged = Expression<Int64?>("taskChanged")
    static let taskCreated = Expression<Int64>("taskCreated")
    static let color = Expression<String?>("color")
    static let list = Table("list")
}

final class FileCache {

    var todoItems = [TodoItem]()
    private(set) var db: Connection?
    private(set) var storage: Storage
    private(set) var context: NSManagedObjectContext?
    
    init(storage: Storage) {
        self.storage = storage
        if storage == .SQL {
            do {
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                let path = documentDirectory!.appendingPathComponent("db.db")
                db = try Connection(path.absoluteString)
                
                try db?.run(SQLModel.list.create(ifNotExists: true) { table in
                    table.column(SQLModel.id, primaryKey: true)
                    table.column(SQLModel.text)
                    table.column(SQLModel.deadline, defaultValue: nil)
                    table.column(SQLModel.importance)
                    table.column(SQLModel.taskCreated)
                    table.column(SQLModel.taskCompleted)
                    table.column(SQLModel.taskChanged, defaultValue: nil)
                    table.column(SQLModel.color, defaultValue: nil)
                })
            }
            catch {
                db = nil
            }
        }
        else if storage == .coreData {
            let container = NSPersistentContainer(name: "TodoItemsModel")
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if (error as NSError?) != nil {
                    return
                }
            })
            self.context = container.viewContext
        }
    }

    func addItem(item: TodoItem) {
        if let index = todoItems.firstIndex(where: {$0.id == item.id}) {
            todoItems[index] = item
        } else {
            todoItems.append(item)
        }
    }

    func removeItem(id: String) {
        if let index = todoItems.firstIndex(where: {$0.id == id}) {
            todoItems.remove(at: index)
        }
    }

    static func getDocumentsDirectory() -> URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return dir[0]
    }
}
