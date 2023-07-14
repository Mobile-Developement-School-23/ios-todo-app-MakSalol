import Foundation
import SQLite
import CoreData

extension FileCache {
    
    func saveToJSONFile(filename: String) {
        
        let filePath = FileCache.getDocumentsDirectory().appending(component: "\(filename).json")
        var arrayOfDictionaries = [[String: Any]]()
        
        todoItems.forEach { todoItem in
            if let dictionary = todoItem.json as? [String: Any] {
                arrayOfDictionaries.append(dictionary)
            }
        }
        
        do {
            let arrayOfData = try JSONSerialization.data(withJSONObject: arrayOfDictionaries, options: .prettyPrinted)
            try arrayOfData.write(to: filePath)
        } catch {
            return
        }
    }
    
    func loadFromJSONFile(filename: String) {
        
        let filePath = FileCache.getDocumentsDirectory().appending(component: "\(filename).json")
        
        do {
            guard let arrayOfDictionaries = try String(contentsOf: filePath).data(using: .utf8),
                  let dictionaries = try JSONSerialization.jsonObject(with: arrayOfDictionaries) as? [[String: Any]]
            else {
                return
            }
            
            dictionaries.forEach { item in
                if let todoItem = TodoItem.parse(json: item) {
                    addItem(item: todoItem)
                }
            }
        } catch {
            return
        }
    }
}

extension FileCache {
    
    func loadFromCSVFile(filename: String) {
        
        let filePath = FileCache.getDocumentsDirectory().appending(component: "\(filename).csv")
        
        var csvString = ""
        do {
            csvString = try String(contentsOf: filePath)
        } catch {
            return
        }
        
        var csvStringComponents = csvString.components(separatedBy: "\n")
        csvStringComponents.removeFirst()
        
        for component in csvStringComponents {
            if let todoItem = TodoItem.parse(csv: component) {
                addItem(item: todoItem)
            }
        }
    }
    
    func saveToCSVFile(filename: String) {
        
        let filePath = FileCache.getDocumentsDirectory().appending(component: "\(filename).csv")
        var csvString = "id;text;deadline;importance;taskCompleted;taskCreated;taskChanged\n"
        
        for item in todoItems {
            csvString.append(item.csv)
        }
        
        do {
            try csvString.write(to: filePath, atomically: true, encoding: .utf8)
        } catch {
            return
        }
    }
}


extension FileCache {
    
    private func saveCoreData() {
        do {
            try self.context?.save()
        } catch {
            print("Error saving context")
        }
    }
    
    func Load() {
        if self.storage == .SQL {
            guard let dbConnection = db else { return }
            do {
                for item in try dbConnection.prepare("Select * FROM list") {
                    if let validItem = TodoItem.parse(raw: item as [Any]) {
                        addItem(item: validItem)
                    }
                }
            } catch {
                return
            }
        }
        else if self.storage == .coreData {
            guard let context = self.context else { return }
            let request: NSFetchRequest<Item> = Item.fetchRequest()
            do {
                let coreArray = try context.fetch(request)
                for coreItem in coreArray {
                    if let item = TodoItem.parse(entity: coreItem) {
                        addItem(item: item)
                    }
                }
            }
            catch {
                print("error adding item from coreData")
                return
            }
        }
    }
    
    func Update(item: TodoItem) {
        
        if self.storage == .SQL {
            guard let dbConnection = db else { return }
            
            do {
                try dbConnection.execute(item.sqlReplaceStatement)
            }
            catch {
                return
            }
        }
        else if self.storage == .coreData {
            guard let context = self.context else { return }
            let request: NSFetchRequest<Item> = Item.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", item.id)
            
            do {
                let coreArray = try context.fetch(request)
                if var updatingItem = coreArray.first(where: {$0.id == item.id}) {
                    updatingItem = TodoItem.coreItem(item: item, context: context)
                    saveCoreData()
                }
            }
            catch {
                print("error deleting item from coreData")
                return
            }
        }
    }
    
    func Delete(item: TodoItem) {
        
        if storage == .SQL {
            guard let dbConnection = db else { return }
            
            do {
                try dbConnection.execute(item.sqlDeleteStatement)
            }
            catch {
                return
            }
        }
        else if self.storage == .coreData {
            guard let context = self.context else { return }
            let request: NSFetchRequest<Item> = Item.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", item.id)
            
            do {
                let coreArray = try context.fetch(request)
                if let deletingItem = coreArray.first(where: {$0.id == item.id}) {
                    context.delete(deletingItem)
                    saveCoreData()
                }
            }
            catch {
                print("error deleting item from coreData")
                return
            }
        }
    }
    
    func Insert(item: TodoItem) {
        
        if self.storage == .SQL {
            guard let dbConnection = db else { return }
            
            do {
                try dbConnection.execute(item.sqlInsertStatement)
            }
            catch {
                print("error inserting")
                return
            }
        }
        else if self.storage == .coreData {
            guard let context = self.context else { return }
            let newItem = TodoItem.coreItem(item: item, context: context)
            saveCoreData()
        }
    }
}
