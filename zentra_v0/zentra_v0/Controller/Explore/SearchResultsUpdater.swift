//
//  SearchResultsUpdater.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 25/9/2025.
//



import UIKit

// MARK: - Protocol
/// Delegate protocol to handle search query updates.
protocol SearchResultsUpdaterDelegate: AnyObject {
    
    /// Called when the search query should be performed.
    /// - Parameter query: The text entered in the search bar.
    func performSearch(query: String)
}

// MARK: - Search Results Updater
/// Handles updating search results for a UISearchController and delegates the query.
class SearchResultsUpdater: NSObject, UISearchResultsUpdating {
    
    /// Delegate to handle the search action.
    weak var delegate: SearchResultsUpdaterDelegate?
    
    
    /// Called automatically when the UISearchController's search bar text changes.
    /// - Parameter searchController: The UISearchController being updated.
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.isEmpty else { return }
        delegate?.performSearch(query: query)
    }
}

