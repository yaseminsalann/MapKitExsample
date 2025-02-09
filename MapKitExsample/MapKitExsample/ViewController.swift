//
//  ViewController.swift
//  MapKitExsample
//
//  Created by Yasemin salan on 10.02.2025.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    
    //kullanıcını konumu ile ilgili işlemler yapılırken kullnılır.
   var locationManager =  CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        //konumun verisi ne kadar keskinlikle  bulunacağı bilgisi verilir.kCLLocationAccuracyBest seçilebilir en iyi sonucu verir ancak bunun sonucunda telefon pili çok gider bu sebeple duruma göre seçilmeli
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //kullanıcıdan izin istenir.yine duruma göre seçilir her zamanmı yoksa uygulama açıkkenmi vb durumlara göre seçilmeli.aşağıda uygulama çık olduğunda konum bilgisini kullanılması seçilmişdir.
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //güncellenen lokasyonları dizi içinde döndürür.içinde enlem ve boylam bilgisi bulunur.
        //enlem ve boylamlardan oluşan konum çizmemiz için gerekli objedir
        //locations[0].coordinate diyerek şuan kullanıcının bulunduğu konum bilgileri verilmişdir.buraya istenilen konum bilgiside verilebilir.
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        //zoom seviyesi
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        //yukarıdaki verilen bilgilere göre haritada belirtilen enlem ve boylama zoomlama yaparak konum göstermiş olduk.
    }
}

