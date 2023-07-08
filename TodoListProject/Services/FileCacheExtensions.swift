import Foundation


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
