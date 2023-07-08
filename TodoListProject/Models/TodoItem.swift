import Foundation

enum ImportanceType: String, CaseIterable {
    case low
    case basic
    case important
}

struct TodoItem {
    let id: String
    let text: String
    let deadline: Date?
    let importance: ImportanceType
    var taskCompleted: Bool
    let taskCreated: Date
    let taskChanged: Date?
    let color: HEX?
    let lastUpdatedBy: String
    
    init(id: String = UUID().uuidString,
         text: String,
         deadline: Date? = nil,
         importance: ImportanceType,
         taskCompleted: Bool,
         taskCreated: Date = Date.now,
         taskChanged: Date? = nil,
         color: HEX? = nil,
         lastUpdatedBy: String = "MyIphone") {
        
        self.id = id
        self.text = text
        self.deadline = deadline
        self.importance = importance
        self.taskCompleted = taskCompleted
        self.taskCreated = taskCreated
        self.taskChanged = taskChanged
        self.color = color
        self.lastUpdatedBy = lastUpdatedBy
    }
}
