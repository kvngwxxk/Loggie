//
//  CoreDataManager.swift
//  Loggie
//
//  Created by Kangwook Lee on 5/27/25.
//
import CoreData

final class CoreDataManager {
    nonisolated(unsafe) static let shared = CoreDataManager()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let bundleURL = Bundle.main.url(forResource: "Loggie_LoggieNetwork", withExtension: "bundle")!
        let resourceBundle = Bundle(url: bundleURL)!
        guard let modelURL = resourceBundle.url(forResource: "LoggieNetworkLogModel", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("❌ 모델 로드 실패")
        }
        
        let container = NSPersistentContainer(name: "LoggieNetworkLogModel", managedObjectModel: model)
        container.persistentStoreDescriptions.first!.shouldMigrateStoreAutomatically = true
        container.persistentStoreDescriptions.first!.shouldInferMappingModelAutomatically = true
        
        container.loadPersistentStores { desc, error in
            if let e = error { fatalError("스토어 로딩 실패: \(e)") }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var context: NSManagedObjectContext { persistentContainer.viewContext }
    func backgroundContext() -> NSManagedObjectContext { persistentContainer.newBackgroundContext() }
    
    func save(isBackground: Bool = false) {
        let ctx = isBackground ? backgroundContext() : context
        guard ctx.hasChanges else { return }
        do { try ctx.save() }
        catch {
            let nserror = error as NSError
            fatalError("[Core Data] 저장 실패: \(nserror), \(nserror.userInfo)")
        }
    }
    
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
                print("데이터 삭제 실패 (\(name)): \(error)")
            }
        }
        completion?( lastError.map(Result.failure) ?? .success(()) )
    }
}
