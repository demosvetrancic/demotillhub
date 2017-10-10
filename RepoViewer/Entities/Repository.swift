//
//  Repository.swift
//  RepoViewer
//
//  Created by Svetozar Rancic on 10/10/17.
//  Copyright © 2017 svetrancic. All rights reserved.
//

import UIKit
import CoreData


/// managed object for repo entity
class Repository: NSManagedObject {
    
    // MARK: Note
    // Probably should have another Entity(NSManagedObject) for User(in our case Owner) and make the relationship between Repository/User by ToOne/ToMany, respectively, but there is no need for that in this demo. If the demo should be extended, would definitely need to make another entity and relationship
    
    /// 
    /// Method to find object within Db or create new Repository object. Using predicate by repoId to distinct objects.
    ///
    ///
    /// - Parameters:
    /// - repoInfo: dictionary with info about repo
    /// - context: <#context description#>
    /// - Returns: <#return value description#>
    /// - Throws: <#throws value description#>
    class func findOrCreateRepo(matching repoInfo: NSDictionary, in context: NSManagedObjectContext) throws -> Repository
    {
        let request: NSFetchRequest<Repository> = Repository.fetchRequest()
        
        request.predicate = NSPredicate(format: "repoId = %@", String(repoInfo[RepositoryKey.identifier] as! Int64))
        do {
            let matches = try context.fetch(request)
            if matches.count > 0 {
                // assert uniqueness: should crash if repoId is not unique
                assert(matches.count == 1, "RepoInfo.findOrCreateTweet -- database inconsistency")
                return matches[0]
            }
        } catch {
            //rethrow error
            throw error
        }
        // no match
        let repo = Repository(context: context)
        repo.repoId = repoInfo[RepositoryKey.identifier] as! Int64
        repo.name = repoInfo[RepositoryKey.name] as! String?
        repo.ownerLoginName = repoInfo.value(forKeyPath: RepositoryKey.ownerLoginName) as? String
        repo.size = repoInfo[RepositoryKey.size] as! Int64
        repo.hasWiki = repoInfo[RepositoryKey.hasWiki]  as! Bool
        
        return repo
        
    }
    
}
