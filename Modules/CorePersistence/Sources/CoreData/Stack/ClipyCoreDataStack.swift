//
//  ClipyCoreDataStack.swift
//  Clipy
//
//  Created by 박민서 on 5/5/26.
//

import CoreData
import Foundation

public final class ClipyCoreDataStack {
    private enum Constant {
        static let modelName = "ClipyPersistence"
        static let sqliteFileName = "ClipyPersistence.sqlite"
    }

    private let persistentContainer: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    public init(storeType: String = NSSQLiteStoreType, storeURL: URL? = nil) throws {
        let model = try Self.makeManagedObjectModel()
        let container = NSPersistentContainer(name: Constant.modelName, managedObjectModel: model)
        let storeDescription = NSPersistentStoreDescription()
        storeDescription.type = storeType
        storeDescription.url = try storeURL ?? Self.defaultStoreURL(for: storeType)
        storeDescription.shouldMigrateStoreAutomatically = true
        storeDescription.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions = [storeDescription]

        let loadSemaphore = DispatchSemaphore(value: 0)
        var loadResult: Result<Void, Error>?

        container.loadPersistentStores { _, error in
            if let error {
                loadResult = .failure(error)
            } else {
                loadResult = .success(())
            }
            loadSemaphore.signal()
        }

        loadSemaphore.wait()

        if case let .failure(error) = loadResult {
            throw ClipyCoreDataError.storeLoadFailed(error)
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer = container
    }

    func performBackgroundTask<T>(
        _ block: @escaping (NSManagedObjectContext) throws -> T
    ) async throws -> T {
        try await persistentContainer.performBackgroundTask { context in
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            return try block(context)
        }
    }

    private static func makeManagedObjectModel() throws -> NSManagedObjectModel {
        let bundle = Bundle(for: ClipyCoreDataStack.self)
        let modelURL = bundle.url(forResource: Constant.modelName, withExtension: "momd")
            ?? bundle.url(forResource: Constant.modelName, withExtension: "mom")

        guard let modelURL else {
            throw ClipyCoreDataError.modelNotFound(Constant.modelName)
        }

        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            throw ClipyCoreDataError.modelLoadFailed(modelURL)
        }

        return model
    }

    private static func defaultStoreURL(for storeType: String) throws -> URL {
        if storeType == NSInMemoryStoreType {
            return URL(fileURLWithPath: "/dev/null")
        }

        guard let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw ClipyCoreDataError.applicationSupportNotFound
        }

        do {
            try FileManager.default.createDirectory(at: baseURL, withIntermediateDirectories: true)
        } catch {
            throw ClipyCoreDataError.directoryCreationFailed(error)
        }

        return baseURL.appendingPathComponent(Constant.sqliteFileName)
    }
}
