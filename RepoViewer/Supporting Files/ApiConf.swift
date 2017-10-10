//
//  ApiConf.swift
//  RepoViewer
//
//  Created by Svetozar Rancic on 10/10/17.
//  Copyright © 2017 svetrancic. All rights reserved.
//

import Foundation




struct GitApi
{
    
    static let defaultURL = "https://api.github.com/search/repositories?q=tetris"
    static let baseURL = "https://api.github.com/"
    static let defaultParam = "tetris"

}

enum GitApiService : String
{
    case searchRepository = "search/repositories"
}


