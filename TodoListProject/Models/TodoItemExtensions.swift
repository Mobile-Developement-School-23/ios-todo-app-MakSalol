import Foundation


extension TodoItem {

    static func parse(json: Any) -> TodoItem? {

        guard let jsonDict = json as? [String: Any] else { return nil }

        let dateFormatter = DateFormats().dateFormatter

        guard let id = jsonDict["id"] as? String,
              let text = jsonDict["text"] as? String,
              let taskCreatedString = jsonDict["taskCreated"] as? String,
              let taskCompletedString = jsonDict["taskCompleted"] as? String,

              let taskCreated = dateFormatter.date(from: taskCreatedString),
              let taskCompleted = Bool(taskCompletedString)
        else {
            return nil
        }

        var importance: ImportanceType = ImportanceType.common
        if let importanceString = jsonDict["importance"] as? String {
            importance = ImportanceType(rawValue: importanceString) ?? ImportanceType.common
        }

        var deadline: Date?
        if let deadlineString = jsonDict["deadline"] as? String {
            deadline = dateFormatter.date(from: deadlineString)
        }

        var taskChanged: Date?
        if let taskChangedString = jsonDict["taskChanged"] as? String {
            taskChanged = dateFormatter.date(from: taskChangedString)
        }

        let color = jsonDict["color"] as? HEX

        let todoItem = TodoItem(id: id, text: text, deadline: deadline, importance: importance, taskCompleted: taskCompleted, taskCreated: taskCreated, taskChanged: taskChanged, color: color)

        return todoItem
    }

    var json: Any {

        let dateFormatter = DateFormats().dateFormatter

        var dictionary = [
            "id": id,
            "text": text,
            "taskCompleted": String(taskCompleted),
            "taskCreated": dateFormatter.string(from: taskCreated)
        ] as [String: Any]

        dictionary["deadline"] = deadline != nil ? dateFormatter.string(from: deadline!) : nil
        dictionary["taskChanged"] = taskChanged != nil ? dateFormatter.string(from: taskChanged!) : nil
        dictionary["importance"] = importance != .common ? importance.rawValue : nil
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
              let importance = importanceString != "" ? ImportanceType(rawValue: importanceString) : ImportanceType.common
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
        let importanceString: String = importance != .common ? importance.rawValue : ""

        let csvString = "\(id);\(text);\(deadlineString);\(importanceString);\(taskCompleted);\(dateFormatter.string(from: taskCreated));\(taskChangedString)\n"

        return csvString
    }
}
