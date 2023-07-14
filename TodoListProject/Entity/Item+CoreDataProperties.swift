//
//  Item+CoreDataProperties.swift
//  TodoListProject
//
//  Created by Максим on 14.07.2023.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var id: String?
    @NSManaged public var text: String?
    @NSManaged public var taskCreated: Date?
    @NSManaged public var deadline: Date?
    @NSManaged public var taskChanged: Date?
    @NSManaged public var taskCompleted: Bool
    @NSManaged public var color: String?
    @NSManaged public var importance: String?

}

extension Item : Identifiable {

}
