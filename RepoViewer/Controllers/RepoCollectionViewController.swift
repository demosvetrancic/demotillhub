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
class RepoCollectionViewController : FetchedResultsCollectionViewController
{
    // MARK: Outlets
    var refreshControl : UIRefreshControl? = UIRefreshControl()

    
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
    
    
    ///  attached fetched result controller instance
    var fetchedResultsController : NSFetchedResultsController<Repository>?

    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //recheck
        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        //preparing otulets
        self.addRefreshControl()
        //preparing props
        self.searchTerm = GitApi.defaultParam
        
    }
    
    
    //MARK: Outlet setups
    /// post fetching refresh method. after accumulating fetch pages with same terms, filters up the existing data with the latest - currentTerm
    ///Predicate - filtering the results with the ones who match case with the currentTerm (thats why there may not be all 10 objects from the batch)
    ///would not need any predicate if we didnt want to accumulate objects from different terms
    func updateUI()
    {
        if let context = container?.viewContext, searchTerm != nil
        {
            let request: NSFetchRequest<Repository> = Repository.fetchRequest()
            
            //using standard comparison to filter the acumulated objects.
            let selector = #selector(NSString.localizedStandardCompare(_:))
            
            
            request.predicate = NSPredicate(format: "name contains[c] %@", searchTerm!)
            
            request.sortDescriptors = [NSSortDescriptor(key: RepositoryKey.name, ascending: true, selector:selector)]
            fetchedResultsController = NSFetchedResultsController<Repository>(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            try? fetchedResultsController?.performFetch()
            collectionView?.reloadData()
        }
    }
    
    
    //MARK: CollectionViewDelegate
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Repository Cell", for: indexPath)
        
        //using frc to get obj and update the cell with info
        if let repoObject = fetchedResultsController?.object(at: indexPath), let repoCell = cell as? RepoCollectionViewCell {
            
            repoCell.updateOutlets(withName: repoObject.name,
                                   withOwner: repoObject.ownerLoginName,
                                   withSize: String(repoObject.size),
                                   withEstimatedTime: String(format: "%.2f",
                                                             Float(repoObject.size/GitApi.defaultBandwith)),
                                   withWiki: repoObject.hasWiki)
            
        }
        
        
        
        return cell;
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
        
    }
    
 
    
    /// Preparing Header View with textfield for search
    ///
    /// - Parameters:
    ///   - collectionView: <#collectionView description#>
    ///   - kind: <#kind description#>
    ///   - indexPath: <#indexPath description#>
    /// - Returns: <#return value description#>
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header ReusableView", for: indexPath)
        if let headerView = header as? HeaderCollectionReusableView
        {
            headerView.textField.delegate = self
        }
        return header
    }
    
}




// MARK: - Extension for fethcing and data updating
extension RepoCollectionViewController
{
    
    
    /// fetching repos with page from network
    ///
    /// - Parameters:
    ///   - term: <#term description#>
    ///   - page: <#page description#>
    func fetchRepos(withTerm term:String?, withPage page: Int)
    {
        BaseService.shared.getRepos(withParam: term,
                                    withPage: page,
                                    withCompletion: {
                                        (items, totalCount) in
                                        
                                        if (items != nil)
                                        {
                                            self.totalPages = totalCount/GitApi.defaultPerPage
                                            self.updateDatabase(with: items!)
                                            //self?.searchTerm = "tetris"
                                            self.refreshControl?.endRefreshing()
                                        }
                                        else
                                        {
                                            self.refreshControl?.endRefreshing()
                                        }
                                        
                                        
        })
    }
    
    
    /// Updateing database with fetched repos. does perform distinct addition to db
    ///
    /// - Parameter repos: <#repos description#>
    func updateDatabase(with repos: [[String: Any]])
    {
        print("loading database..")
        container?.performBackgroundTask
            {
                [weak self] context in
                
                for repoInfo in repos
                {
                    _ = try? Repository.findOrCreateRepo(matching: repoInfo as NSDictionary, in: context)
                }
                try? context.save()
                print("done loading database.")
                self?.printDatabaseStatistics()
        }
    }
    
    
    
    /// Prints some inforamtion for checkings on safe thread
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
                //todo
                self.updateUI()
                
            }
        }
    }
    
    
    
    
}




// MARK: - UIRefreshControl
extension RepoCollectionViewController
{
    
    func addRefreshControl()
    {
        //refreshControl = UIRefreshControl()
        refreshControl?.tintColor = .gray
        
        refreshControl?.attributedTitle = NSAttributedString(string:NSLocalizedString("Fetching for current term", comment: ""))
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView?.addSubview(refreshControl!)
        collectionView?.alwaysBounceVertical = true
    }
    
    func refresh()
    {
        if (currentPage<=totalPages)
        {
            print("paging")
            fetchRepos(withTerm: searchTerm, withPage: currentPage)
            currentPage+=1
        }
    }
    
}


// MARK: - UITextFieldDelegate
extension RepoCollectionViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchTerm = textField.text
        return true
    }
}

