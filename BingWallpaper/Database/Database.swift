//
//  Database.swift
//  BingWallpaper
//
//  Created by Laurenz Lazarus on 24.03.24.
//

import Foundation
import Cocoa

class Database {
    static let instance = Database()
    
    private init() { }
    
    @MainActor
    func allImageDescriptors() -> [ImageDescriptor] {
        let fetchRequest = NSFetchRequest<ImageDescriptor>(entityName: "ImageDescriptor")
        
        do {
            return try persistentContainer.viewContext
                .fetch(fetchRequest)
                .sorted()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }
    
    @MainActor
    func deleteImageDescriptors(olderThan oldestDateStringToKeep: String) throws {
        let managedContext = persistentContainer.viewContext
        
        allImageDescriptors()
            .filter { $0.startDate <= oldestDateStringToKeep }
            .forEach { managedContext.delete($0) }
        
        try managedContext.save()
    }
    
    @MainActor
    func updateImageDescriptors(from imageEntries: [DownloadManager.ImageEntry]) -> [ImageDescriptor] {
        let managedContext = persistentContainer.viewContext
        let preservedStartDates = allImageDescriptors()
            .map { $0.startDate }
        
        let imageDescriptors = imageEntries
            .filter { imageEntry in preservedStartDates.contains(imageEntry.startdate) == false }
            .map { image -> ImageDescriptor in
                ImageDescriptor.instantiate(from: image, in: managedContext)
            }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        return imageDescriptors
    }
    
    
    // MARK: - Core Data stack
    
    private func entityDescription() -> NSEntityDescription {
        let entity = NSEntityDescription()
        entity.name = "ImageDescriptor"
        entity.managedObjectClassName = NSStringFromClass(ImageDescriptor.self)
        
        // Attributes
        let startDateAttr = NSAttributeDescription()
        startDateAttr.name = "startDate"
        startDateAttr.attributeType = .stringAttributeType
        startDateAttr.isOptional = false
        
        let endDateAttr = NSAttributeDescription()
        endDateAttr.name = "endDate"
        endDateAttr.attributeType = .stringAttributeType
        endDateAttr.isOptional = false
        
        let imageUrlAttr = NSAttributeDescription()
        imageUrlAttr.name = "imageUrl"
        imageUrlAttr.attributeType = .URIAttributeType
        imageUrlAttr.isOptional = false
        
        let descriptionStringAttr = NSAttributeDescription()
        descriptionStringAttr.name = "descriptionString"
        descriptionStringAttr.attributeType = .stringAttributeType
        descriptionStringAttr.isOptional = false
        
        let copyrightUrlAttr = NSAttributeDescription()
        copyrightUrlAttr.name = "copyrightUrl"
        copyrightUrlAttr.attributeType = .URIAttributeType
        copyrightUrlAttr.isOptional = false
        
        entity.properties = [
            startDateAttr,
            endDateAttr,
            imageUrlAttr,
            descriptionStringAttr,
            copyrightUrlAttr
        ]
        
        return entity
    }
    
    private func managedObjectModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        model.entities = [entityDescription()]
        return model
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel", managedObjectModel: managedObjectModel())
        
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}
