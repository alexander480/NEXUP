//
//  ArtistVC.swift
//  TheLocalPlug
//
//  Created by Alexander Lester on 1/6/18.
//  Copyright © 2018 LAGB Technologies. All rights reserved.
//

import Foundation

import UIKit
import GoogleMobileAds
import AVFoundation

import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

//  TODO
// ----------------------------------------------
//
// - Initialize As FavoritesVC If Clicked On Appropriate Button
// - Initialize As DislikesVC If Clicked On Appropriate Button
// - Initialize As RecentlyPlayedVC If Clicked On Appropriate Button
//

var artistSelected = [String: String]()

class ArtistVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var circleButton: ButtonClass!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var artistClass = Artists()
    var artists = [[String: String]]()
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if let info = audio.metadata {
            if let image = audio.imageCache.object(forKey: info["URL"] as! NSString) {
                backgroundImage.image = image
                backgroundImage.blur()
                self.circleButton.setImage(image, for: .normal)
            }
        }
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (timer) in self.updateUserInterface() })
    }
    
    private func updateUserInterface() {
        self.artists = artistClass.artists
        self.tableView.reloadData()
        if let info = audio.metadata {
            if let image = info["Image"] as? UIImage {
                self.circleButton.setImage(image, for: .normal)
            }
        }
        if let item = audio.player.currentItem {
            self.progressBar.progress = Float(item.currentTime().seconds / item.duration.seconds)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 { return 175 }
        // else if indexPath.row == 1 { return 90.5 }
        else { return 100 }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if artists.isEmpty { return 1 /*2*/ }
        else { return artists.count + 1 /*2*/ }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        if row == 0 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "ArtistHeaderCell") as! ArtistHeaderCell
            cell.cellTitle?.text = "Browse Artists"
            cell.cellDetail?.text = "Check Out Featured Artists"
            return cell
        }
            
//        if row == 1 {
//            let cell: AdCell = tableView.dequeueReusableCell(withIdentifier: "AdCell", for: indexPath) as! AdCell
//            let bannerView = cell.cellBannerView(rootVC: self, frame: cell.bounds)
//            bannerView.adSize = GADAdSizeFromCGSize(CGSize(width: view.bounds.size.width, height: 90))
//
//            for view in cell.contentView.subviews { if view.isMember(of: GADBannerView.self) { view.removeFromSuperview() } }
//
//            cell.addSubview(bannerView)
//
//            DispatchQueue.global(qos: .background).async() {
//                let request = GADRequest()
//                request.testDevices = [kGADSimulatorID]
//                DispatchQueue.main.async() { bannerView.load(request) }
//            }
//
//            return cell
//        }
            
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistCell") as! ArtistCell
            if let name = artists[row - 1 /*2*/]["Name"], let url = artists[row - 1 /*2*/]["ImageURL"] { cell.artistName?.text = name; cell.artistImage?.imageFrom(urlString: url) }
            else { cell.artistName?.text = "Loading"; cell.artistImage?.image = nil }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ArtistInfoVC") as? ArtistInfoVC {
            artistSelected = self.artists[indexPath.row - 1 /*2*/]
            present(vc, animated: true, completion: nil)
        }
    }
}
