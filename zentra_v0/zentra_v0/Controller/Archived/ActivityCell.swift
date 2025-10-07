//
//
////
////  PlanCell.swift
////  zentra_v0
////
////  Created by Evelyn Tran on 22/9/2025.
////
//
//import UIKit
//
//class ActivityCell: UITableViewCell {
//
//    @IBOutlet weak var activityImageView: UIImageView!
//    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var descriptionLabel: UILabel!
//    @IBOutlet weak var durationLabel: UILabel!
//    @IBOutlet weak var tagsStackView: UIStackView!
//    @IBOutlet weak var ratingStackView: UIStackView!
//
//    func configure(with activity: Activity) {
//        titleLabel.text = activity.type.rawValue
//        descriptionLabel.text = activity.description
////        durationLabel.text = activity.durationText
//
//        // Example: dynamically add tags
//        tagsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
//        for tag in activity.tags {
//            let label = UILabel()
//            label.text = tag
//            label.font = .systemFont(ofSize: 12)
//            label.textColor = .white
//            label.backgroundColor = .systemBlue
//            label.layer.cornerRadius = 8
//            label.clipsToBounds = true
//            label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//            tagsStackView.addArrangedSubview(label)
//        }
//
//        // TODO: configure rating stars and image
//    }
//}
//
