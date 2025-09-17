//
//  VibeSelectionViewController.swift
//  zentra_v0
//
//  Created by Evelyn Tran on 17/9/2025.
//

import UIKit
import CoreLocation

class VibeSelectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let moods: [Mood] = [
        Mood(id: "1", name: "Adventure", keyword: "hiking"),
        Mood(id: "2", name: "Relaxation", keyword: "spa"),
        Mood(id: "3", name: "Culture", keyword: "museum"),
        Mood(id: "4", name: "Foodie", keyword: "restaurant")
    ]
    
    let location = CLLocationCoordinate2D(latitude: -37.8136, longitude: 144.9631) // Melbourne
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return moods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoodCell", for: indexPath) as! MoodCell
        cell.titleLabel.text = moods[indexPath.item].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mood = moods[indexPath.item]
        let service = PlacesService()
        service.fetchActivities(for: mood, location: location) { activities in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "ActivityDetailVC") as? ActivityDetailViewController {
                vc.activities = activities
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
