//
//  ViewController.swift
//  MapKitExsample
//
//  Created by Yasemin salan on 10.02.2025.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var commentTextField: UITextField!
    
    //kullanıcını konumu ile ilgili işlemler yapılırken kullnılır.
   var locationManager =  CLLocationManager()
    var choosenLatitude = Double()
    var choosenLongitude = Double()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        //konumun verisi ne kadar keskinlikle  bulunacağı bilgisi verilir.kCLLocationAccuracyBest seçilebilir en iyi sonucu verir ancak bunun sonucunda telefon pili çok gider bu sebeple duruma göre seçilmeli
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //kullanıcıdan izin istenir.yine duruma göre seçilir her zamanmı yoksa uygulama açıkkenmi vb durumlara göre seçilmeli.aşağıda uygulama çık olduğunda konum bilgisini kullanılması seçilmişdir.
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //
        let gestureRecognizer = UILongPressGestureRecognizer(target:self, action: #selector(chooseLocation(gestureRecognizer: )))
        //kaç saniye basıldığı bilgisi verilir.
        gestureRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    @objc func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer) {
        //gestureRecognizer fonskiyonlarını kullanabilmek için fonksiyon içine input olarak alıyoruz.
        //
        if gestureRecognizer.state == .began {
            //dokunma işlemi algılandıysa bu blok içindeki işlemler yapılır
            //touchPoint değişkeni dokunulan kordinatları tutar
            let touchPoint = gestureRecognizer.location(in: mapView)
            let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            choosenLatitude = touchCoordinate.latitude
            choosenLongitude = touchCoordinate.longitude
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            annotation.title = nameTextField.text
            annotation.subtitle = commentTextField.text
            self.mapView.addAnnotation(annotation)
        }
        
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
    
    @IBAction func saveClickButton(_ sender: Any) {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        newPlace.setValue(nameTextField.text, forKey: "title")
        newPlace.setValue(commentTextField.text, forKey: "subtitle")
        newPlace.setValue(choosenLatitude, forKey: "latitude")
        newPlace.setValue(choosenLongitude, forKey: "longitude")
        newPlace.setValue(UUID(), forKey: "id")
        do{
            try context.save()
            print("success")
        }catch{
            print("error")
        }
    }
    
}

