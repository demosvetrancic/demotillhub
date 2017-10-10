//
//  ApiConf.swift
//  RepoViewer
//
//  Created by Svetozar Rancic on 10/10/17.
//  Copyright © 2017 svetrancic. All rights reserved.
//


import Foundation


struct RepositoryKey
{
    
    //Response key - array of Repos
    static let responseItems = "items"
    //Response key - total count in array of repos
    static let responseTotalCount = "total_count"
    
    //Repo Keys
    static let name = "name"
    static let owner = "owner"
    static let ownerLoginName = "owner.login"
    static let hasWiki = "has_wiki"
    static let size = "size"
    static let identifier = "id"
    
}

struct GitApi
{
    
    static let defaultURL = "https://api.github.com/search/repositories?q=tetris"
    static let baseURL = "https://api.github.com/"
    static let perPageParam = "&per_page="
    static let pageParam = "&page="
    static let defaultPerPage = 10
    static let defaultParam = "tetris"
    static let defaultBandwith  = 10000
}

enum GitApiService : String
{
    case searchRepository = "search/repositories"
}


struct RepoCellStyle
{
    static let hasWikiColor = 0xFFC766
    static let hasNoWikiColor = 0xFFFFFFFF
    
}
