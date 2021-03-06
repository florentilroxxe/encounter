//
//  Persistence.swift
//  encounter
//
//  Created by Florent Alexandre on 10/05/2021.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for index in 0..<10 {
            let newEnemy = Fighter(context: viewContext)
            newEnemy.name = "Gnome"
            newEnemy.index = Int64(index)
            newEnemy.healthPoints = 10
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "encounter")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print("failed to save in DB \(error)")
            }
        }
    }
    
    func lastIndexForEnemy(type: String) -> Int {
        
        let fetchRequest = NSFetchRequest<Fighter>(entityName: "Fighter")
        fetchRequest.predicate = NSPredicate(format: "ANY name BEGINSWITH[c] %@", type)
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Fighter.index, ascending: false)
        ]
        
        do {
            let enemies = try container.viewContext.fetch(fetchRequest) 
            return Int(enemies.first?.index ?? 0)
        } catch let error {
            print("Couldn't fetch enemies of type \(error)")
            return 0
        }
        
    }
    
    
}
