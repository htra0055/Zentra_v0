// ActivityDetailViewController.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 17/9/2025.



import UIKit

class ActivityDetailViewController: UIViewController {
    
    
}



import UIKit

class ActivityCardCell: UICollectionViewCell {
    let titleLabel = UILabel()
    let ratingLabel = UILabel()
    let imageView = UIImageView()
    let descriptionLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 16
        contentView.layer.shadowOpacity = 0.2
        contentView.layer.shadowRadius = 6
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError() }

//    func configure(with activity: Activity) {
//        titleLabel.text = activity.name
//        descriptionLabel.text = activity.description
//        ratingLabel.text = "⭐️ \(activity.rating ?? 0)"
//    }

    private func setupLayout() {
        // Add subviews, set constraints
    }
    
    
}


//
// MARK: v0
//
//class ActivityDetailViewController: UITableViewController {
//    
//    var activities: [Activity] = []
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        title = "Suggested Activities"
//    }
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return activities.count
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath)
//        let activity = activities[indexPath.row]
//        cell.textLabel?.text = activity.name
//        cell.detailTextLabel?.text = activity.address
//        return cell
//    }
//}
