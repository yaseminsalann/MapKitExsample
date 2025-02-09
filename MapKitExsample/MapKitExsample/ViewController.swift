//
//  ViewController.swift
//  MapKitExsample
//
//  Created by Yasemin salan on 10.02.2025.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
    }


}

