//
//  ViewController.swift
//  RepoViewer
//
//  Created by Svetozar Rancic on 10/10/17.
//  Copyright © 2017 svetrancic. All rights reserved.
//

import UIKit
import CoreData


/// class for repo collection view scene
class RepoCollectionViewController : UIViewController{
    
    // MARK: Properties
    
    /// presistent container for the scheme model RepoViewer.xcdatamodel
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    /// currentPage that is requested
    var currentPage = 1
    
    /// totalNumber pages - gets by total_count/GitApi.defaultPerPage
    var totalPages = 1
    
    /// current search term for query to git.
    var searchTerm: String?
        {
        /// placing closure on didSet to restart paging and fetch for new term, whenever user sets a new search term
        didSet
        {
            currentPage = 1
            totalPages = 1
            fetchRepos(withTerm: searchTerm, withPage: currentPage)
        }
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        
        self.searchTerm = GitApi.defaultParam
        
    }
    
    private func fetchRepos(withTerm term:String?, withPage page: Int)
    {
        BaseService.shared.getRepos(withParam: term, withPage: page, withCompletion: {
            (items, totalCount) in
            if (items != nil)
            {
                self.totalPages = totalCount/GitApi.defaultPerPage
                self.updateDatabase(with: items!)
                //self?.searchTerm = "tetris"
            }
     
        })
    }
    
    
    private func updateDatabase(with repos: [[String: Any]])
    {
        print("loading database...")
        container?.performBackgroundTask
            {
                [weak self] context in
                
                for repoInfo in repos {
                    _ = try? Repository.findOrCreateRepo(matching: repoInfo as NSDictionary, in: context)
                }
                try? context.save()
                print("done loading database...")
                self?.printDatabaseStatistics()
        }
    }
    
    func printDatabaseStatistics()
    {
        if let context = container?.viewContext {
            // context on main
            context.perform {
                // for security
                if Thread.isMainThread {
                    print("main")
                } else {
                    print("off main")
                }
                
                // checking count not to duplicate same objects
                if let repoCount = try? context.count(for: Repository.fetchRequest())
                {
                    print("Number of repositories: \(repoCount)")
                    
                }
                //todo self.updateOutlets()
                
            }
        }
    }
    

    
    
    


    
}



