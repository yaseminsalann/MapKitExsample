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
    var selectedTitle = ""
    var selectedID:UUID?
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    
    
    
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
        
        if selectedTitle != "" {
            //coreData
            let appDELegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDELegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Places")
            let idString = selectedID!.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@ ",idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        
                        //iç içe if kontrol etmek uygulamayı yavaşlatır ama biz şuan basit çalıştığımız için kullanabiliriz.
                        //tüm durumların kontrolun sağladığımız için iç içe yazdık hepsinin aynı anda doğru olmasını istiyoruz.
                        if let title = result.value(forKey: "title") as? String{
                            annotationTitle = title
                            
                            if let subtitle = result.value(forKey: "subtitle") as? String{
                                annotationSubtitle = subtitle
                                
                                if let latitude = result.value(forKey: "latitude") as? Double{
                                    annotationLatitude = latitude
                                    
                                    if let longitude = result.value(forKey: "longitude") as? Double{
                                        annotationLongitude = longitude
                                        
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotationTitle
                                        annotation.subtitle = annotationSubtitle
                                        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                        annotation.coordinate = coordinate
                                        //mapView da gösteriyoruz.
                                        mapView.addAnnotation(annotation)
                                        nameTextField.text = annotationTitle
                                        commentTextField.text = annotationSubtitle
                                        locationManager.startUpdatingLocation()
                                        
                                        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        let region: MKCoordinateRegion = MKCoordinateRegion(center: coordinate, span: span)
                                        mapView.setRegion(region, animated: true)
                                        
                                        
                                    }
                                }
                                
                            }
                            
                        }
                    }
                }
            }catch{
                print("error")
            }
            
            
        }
        else{
            //Add New Data
        }
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
        if selectedTitle == ""{
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
        else{
            
        }
       
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

