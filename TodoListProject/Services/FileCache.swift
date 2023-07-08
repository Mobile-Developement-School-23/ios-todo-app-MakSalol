import Foundation


final class FileCache {

    private(set) var todoItems = [TodoItem]()

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
