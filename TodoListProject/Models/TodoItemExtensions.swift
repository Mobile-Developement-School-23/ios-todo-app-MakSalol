import Foundation


extension TodoItem {

    static func parse(json: Any) -> TodoItem? {

        guard let jsonDict = json as? [String: Any] else { return nil }

        guard let id = jsonDict["id"] as? String,
              let text = jsonDict["text"] as? String,
              let taskCreatedString = jsonDict["created_at"] as? Double,
              let taskCompletedString = jsonDict["done"] as? Int

        else {
            return nil
        }
        let taskCompleted = Bool(truncating: taskCompletedString as NSNumber)
        let taskCreated = Date(timeIntervalSince1970: taskCreatedString)
        var importance: ImportanceType = ImportanceType.basic
        if let importanceString = jsonDict["importance"] as? String {
            importance = ImportanceType(rawValue: importanceString) ?? ImportanceType.basic
        }

        var deadline: Date?
        if let deadlineString = jsonDict["deadline"] as? Double {
            deadline = Date(timeIntervalSince1970: deadlineString)
        }

        var taskChanged: Date?
        if let taskChangedString = jsonDict["changed_at"] as? Double {
            taskChanged = Date(timeIntervalSince1970: taskChangedString)
        }

        let color = jsonDict["color"] as? HEX

        let todoItem = TodoItem(id: id, text: text, deadline: deadline, importance: importance, taskCompleted: taskCompleted, taskCreated: taskCreated, taskChanged: taskChanged, color: color)

        return todoItem
    }

    var json: Any {

        var dictionary = [
            "id": id,
            "text": text,
            "done": taskCompleted,
            "created_at": Int64(taskCreated.timeIntervalSince1970),
            "last_updated_by": lastUpdatedBy
        ] as [String: Any]

        dictionary["deadline"] = deadline != nil ? Int64(deadline!.timeIntervalSince1970) : nil
        dictionary["changed_at"] = taskChanged != nil ? Int64(taskChanged!.timeIntervalSince1970) : Int64(Date.now.timeIntervalSince1970)
        dictionary["importance"] = importance.rawValue
        dictionary["color"] = color
        return dictionary
    }
}

extension TodoItem {

    static func parse(csv: String) -> TodoItem? {

        let dateFormatter = DateFormats().dateFormatter
        let components = csv.components(separatedBy: ";")

        if components.count < 7 {
            return nil
        }

        let id = components[0]
        let text = components[1]
        let deadlineString = components[2]
        let importanceString = components[3]
        let taskCompletedString = components[4]
        let taskCreatedString = components[5]
        let taskChangedString = components[6]

        guard let taskCreated = dateFormatter.date(from: taskCreatedString),
              let taskCompleted = Bool(taskCompletedString),
              let importance = importanceString != "" ? ImportanceType(rawValue: importanceString) : ImportanceType.basic
        else { return nil }

        let deadline = dateFormatter.date(from: deadlineString)
        let taskChanged = dateFormatter.date(from: taskChangedString)

        let todoItem = TodoItem(id: id,
                                text: text,
                                deadline: deadline,
                                importance: importance,
                                taskCompleted: taskCompleted,
                                taskCreated: taskCreated,
                                taskChanged: taskChanged)

        return todoItem
    }

    var csv: String {

        let dateFormatter = DateFormats().dateFormatter

        let deadlineString: String = deadline != nil ? dateFormatter.string(from: deadline!) : ""
        let taskChangedString: String = taskChanged != nil ? dateFormatter.string(from: taskChanged!) : ""
        let importanceString: String = importance != .basic ? importance.rawValue : ""

        let csvString = "\(id);\(text);\(deadlineString);\(importanceString);\(taskCompleted);\(dateFormatter.string(from: taskCreated));\(taskChangedString)\n"

        return csvString
    }
}
