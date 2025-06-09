//
//  CoreDataManager.swift
//  Loggie
//
//  Created by Kangwook Lee on 5/27/25.
//
import CoreData

final class CoreDataManager {
    /// Shared singleton instance of the CoreDataManager.
    nonisolated(unsafe) static let shared = CoreDataManager()

    /// Lazy-loaded persistent container for Core Data stack initialization.
    private lazy var persistentContainer: NSPersistentContainer = {
        let bundleURL = Bundle.main.url(forResource: "Loggie_LoggieNetwork", withExtension: "bundle")!
        let resourceBundle = Bundle(url: bundleURL)!
        guard let modelURL = resourceBundle.url(forResource: "LoggieNetworkLogModel", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("❌ Failed to load Core Data model")
        }

        let container = NSPersistentContainer(name: "LoggieNetworkLogModel", managedObjectModel: model)
        container.persistentStoreDescriptions.first!.shouldMigrateStoreAutomatically = true
        container.persistentStoreDescriptions.first!.shouldInferMappingModelAutomatically = true

        container.loadPersistentStores { desc, error in
            if let e = error {
                fatalError("Failed to load persistent store: \(e)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    /// Main context for use on the main thread.
    var context: NSManagedObjectContext { persistentContainer.viewContext }

    /// Returns a new background context for background tasks.
    func backgroundContext() -> NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }

    /// Saves the context to the persistent store if there are changes.
    /// - Parameter isBackground: Whether to save using a background context.
    func save(isBackground: Bool = false) {
        let ctx = isBackground ? backgroundContext() : context
        guard ctx.hasChanges else { return }
        do {
            try ctx.save()
        } catch {
            let nserror = error as NSError
            fatalError("[Core Data] Save failed: \(nserror), \(nserror.userInfo)")
        }
    }

    /// Deletes all data in the `LoggieNetworkLog` entity.
    /// - Parameter completion: Optional completion handler with success or error.
    func deleteAllData(completion: ((Result<Void, Error>) -> Void)? = nil) {
        let ctx = persistentContainer.viewContext
        let coordinator = persistentContainer.persistentStoreCoordinator
        let entityNames = ["LoggieNetworkLog"]
        var lastError: Error?

        for name in entityNames {
            let req = NSFetchRequest<NSFetchRequestResult>(entityName: name)
            let delete = NSBatchDeleteRequest(fetchRequest: req)
            delete.resultType = .resultTypeObjectIDs
            do {
                let result = try coordinator.execute(delete, with: ctx) as? NSBatchDeleteResult
                if let ids = result?.result as? [NSManagedObjectID] {
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: ids], into: [ctx])
                }
            } catch {
                lastError = error
                print("Failed to delete data (\(name)): \(error)")
            }
        }
        completion?( lastError.map(Result.failure) ?? .success(()) )
    }
}
