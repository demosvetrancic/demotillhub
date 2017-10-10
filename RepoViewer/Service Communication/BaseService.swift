//
//  BaseService.swift
//  RepoViewer
//
//  Created by Svetozar Rancic on 10/10/17.
//  Copyright © 2017 svetrancic. All rights reserved.
//

import Foundation
import Alamofire


class BaseService
{
    
    static let shared = BaseService()
    
    private init()
    {}
    
    func getRepos(withParam param: String?, withCompletion completion:@escaping ([[String:Any]]?) -> Void )
    {
        //https://api.github.com/search/repositories?q=tetris
        let urlRequest = "\(GitApi.baseURL)\(GitApiService.searchRepository.rawValue)?q=\(param!)"
        
        Alamofire.request(urlRequest)
            .validate()
            .responseJSON
            { response in
                
                guard response.result.isSuccess else
                {
                    print("Error: \(response.result.error?.localizedDescription)")
                    completion(nil)
                    return
                }
                
                //todo
                print("Github data response: \(response)")
                
                guard let responseJSON = response.result.value as? [String: Any],
                    let items = responseJSON["items"] as? [[String:Any]]
                    else
                {
                    print ("Error parsing")
                    completion(nil)
                    return
                }
                print("Items: \(items)")
                print("FirstSize: \(items.first?["size"])")
                completion(items)
                
                
        }
    }
    
}
