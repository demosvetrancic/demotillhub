//
//  BaseService.swift
//  RepoViewer
//
//  Created by Svetozar Rancic on 10/10/17.
//  Copyright © 2017 svetrancic. All rights reserved.
//

import Foundation
import Alamofire


/// Singleton networking class
class BaseService
{
    
    /// Singleton shared instance
    static let shared = BaseService()
    
    private init()
    {}
    
    /// method to fetch repositories with 'query' parameter and with paging
    ///
    /// - Parameters:
    ///   - param: searchTerm for query
    ///   - page: currentPage to retreive
    ///   - completion: closure
    func getRepos(withParam param: String?,withPage page:Int, withCompletion completion:@escaping ([[String:Any]]?,Int) -> Void )
    {
        //new paging url request, should add as params to af request but...
        //https://api.github.com/search/repositories?q=tetris?
        let urlRequest = "\(GitApi.baseURL)\(GitApiService.searchRepository.rawValue)?q=\(param!)\(GitApi.perPageParam)\(GitApi.defaultPerPage)\(GitApi.pageParam)\(String(page))"
        
        Alamofire.request(urlRequest)
            .validate()
            .responseJSON
            { response in
                
                //checking the results
                guard response.result.isSuccess else
                {
                    print("Error: \(response.result.error?.localizedDescription)")
                    completion(nil, 1)
                    return
                }
                
                //todo
                print("Github data response: \(response)")
                
                //retrieving items and total_count from resposnse
                guard let responseJSON = response.result.value as? [String: Any],
                    let items = responseJSON[RepositoryKey.responseItems] as? [[String:Any]], let totalCount = responseJSON[RepositoryKey.responseTotalCount] as? Int
                    else
                {
                    print ("Error parsing")
                    completion(nil, 1)
                    return
                }
                print("Items: \(items)")
                print("FirstSize: \(items.first?[RepositoryKey.size])")
                
                
                completion(items, totalCount)

        }
    }
    
}
