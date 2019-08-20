//
//  ThumbnailViewController.swift
//  ArraPolyViewTest
//
//  Created by Suraj Roy on 7/10/18.
//  Copyright © 2018 Suraj Roy. All rights reserved.

import UIKit
import Alamofire
import MZAppearance
import MZFormSheetPresentationController
import SDWebImage

class ThumbnailViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    public var completion: ((_ name: String, _ url: String) -> ())?
    
    var names = [String]()
    var thumbnails = [String]()
    var objects = [String]()
    var searchBarText: String = ""
    
    var objURL: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        searchBar.delegate = self
        collectionView.delegate = self
        
        let itemSize = UIScreen.main.bounds.width/5
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        
        collectionView.collectionViewLayout = layout
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBarText = searchBar.text!
        
        self.names.removeAll()
        self.thumbnails.removeAll()
        
        //Get names and thumbnail urls of search
        guard let polyUrl = URL(string: "https://poly.googleapis.com/v1/assets?key=AIzaSyD8G3JkqfZpeKdGXDEqVDuYu_EJ99fKu0w&keywords=" + searchBarText + "&pageSize=25") else {return}
        
        Alamofire.request(polyUrl).responseJSON { (response) in
            if let result = response.result.value {
                typealias JSONDictionary = [String:Any]
                let JSON = result as? NSDictionary
                
                if let assets = JSON!["assets"] as? [JSONDictionary] {
                    
                    for asset in assets {
                        
                        //print (asset["displayName"] as! String)
                        
                        if let formats = asset["formats"] as? [JSONDictionary]{
                            
                            for format in formats {
                                
                                if let roots = format["root"] as? JSONDictionary {
                                    
                                    let obj = roots["relativePath"] as! String
                                    if obj.suffix(3)=="obj" {
                                        
                                        self.names.append(asset["displayName"] as! String)
                                        self.objects.append(roots["url"] as! String)
                                        
                                        if let thumbnail = asset["thumbnail"] as? JSONDictionary {
                                            
                                            //print (thumbnail["url"] as? String ?? "n/a")
                                            self.thumbnails.append(thumbnail["url"] as! String)
                                            
                                        }
                                        
                                    }
                                    
                                    
                                }
                                
                            }

                        }
                        
                    }
                    
                }
                
            }
            
            print(self.names)
            
            self.collectionView.reloadData()
        }
        
    }
    
    @IBAction func isCancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return names.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! thumbnailCell
        cell.imageView.sd_setImage(with: URL(string: thumbnails[indexPath.row]), placeholderImage: UIImage(named: "placeholder.jpg"))
        cell.label.text = names[indexPath.row]
        cell.label.adjustsFontSizeToFitWidth = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.dismiss(animated: true, completion: {

            self.completion?(self.names[indexPath.row], self.objects[indexPath.row])

        })
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
