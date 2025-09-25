//
//  SearchResultsUpdater.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 25/9/2025.
//



import UIKit

protocol SearchResultsUpdaterDelegate: AnyObject {
    func performSearch(query: String)
}

class SearchResultsUpdater: NSObject, UISearchResultsUpdating {
    weak var delegate: SearchResultsUpdaterDelegate?
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.isEmpty else { return }
        delegate?.performSearch(query: query)
    }
}

