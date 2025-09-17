// ActivityDetailViewController.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 17/9/2025.
//

import UIKit

class ActivityDetailViewController: UITableViewController {
    
    var activities: [Activity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Suggested Activities"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath)
        let activity = activities[indexPath.row]
        cell.textLabel?.text = activity.name
        cell.detailTextLabel?.text = activity.address
        return cell
    }
}
