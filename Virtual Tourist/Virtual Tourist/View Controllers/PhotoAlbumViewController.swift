//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by makramia on 25/01/2019.
//  Copyright © 2019 makramia. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PhotoAlbumViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var noPhotosLabel: UILabel!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    var dataController:DataController!
    var pin: Pin?
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    var selectedIndexes = [IndexPath]()
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    var totalPages: Int? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        deleteButton.isEnabled = false
        
        mapView.delegate = self
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        
        if let pin = pin{
          dropPin(pin)
          setupFetchedResultControllerWith(pin)
            
            if let photos = pin.photos, photos.count == 0{
                
                getPhotosFromFlickr(pin)
                
            }
        }
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumLineSpacing = space
        flowLayout.minimumInteritemSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        
        
    }
    

    fileprivate func setupFetchedResultControllerWith(_ pin:Pin) {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self 
        
        do {
            try fetchedResultsController.performFetch()
            
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }

    func getPhotosFromFlickr(_ pin: Pin){
        FlickrClient.sharedInstance().searchPhotosFormFlickerBy(latitude: pin.latitude, longitude: pin.longitude, totalPages: totalPages, { (success, photoData, errorString)  in
            
            if success {
          
                    if let response = photoData as? Response {
                        
                        self.totalPages = response.photos?.pages
                        let totalPhotos = response.photos!.photo.count
                        
                        print("\(#function) Downloading \(totalPhotos) photos.")
                        self.storePhotos(response.photos!.photo, forPin: pin)
                       
                        
                    }else {
                   
                        
                        self.updateNoPhotosLabel("This pin has no images")
                }
                
            }else{
               
                print("\(#function) error:\(errorString!)")
                self.updateNoPhotosLabel("Error: Please try again!")
                self.presentAlertWithTitle(title: "Alert", message: errorString!, options: "OK", completion: { (option) in
                    print("option: \(option)")})
                
            }
            
        })
    }
    
    private func updateNoPhotosLabel(_ text: String) {
        self.performUIUpdatesOnMain {
            self.noPhotosLabel.text = text
        }
    }
    
    private func storePhotos(_ photos: [FlickrURL], forPin: Pin) {
        
        for photo in photos{
            
            performUIUpdatesOnMain {
                
                if let url = photo.url{
                    
                    let newPhoto = Photo(context: self.dataController.viewContext)
                    newPhoto.creationDate = Date()
                    newPhoto.id = photo.id
                    newPhoto.imageUrl = url
                    newPhoto.pin = forPin
                    try?self.dataController.viewContext.save()
                    
                }
            }
            
        }
    }
    
    
    func dropPin(_ pin: Pin){
        
        let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
        
        
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
        mapView.setCenter(annotation.coordinate, animated: true)
    }
    
    @IBAction func deletePhotos(_ sender: UIButton) {
        
        if sender.currentTitle == "New Collection" {
            
            guard let fetchedResults = self.fetchedResultsController.fetchedObjects else {
                return
            }
            
            //photosUrlArray.removeAll()
            
            for i in fetchedResults {
                dataController.viewContext.delete(i)
                try? dataController.viewContext.save()
            }
            
           getPhotosFromFlickr(pin!)
            
        } else if sender.currentTitle == "Remove Selected Pictures" {
            
            sender.setTitle("New Collection", for: .normal)
            
            deletePhotos()
            
            
        }
        
    }
    
    
      func deletePhotos() {
    
        // delete all selected photos
        
        var photosToDelete: [Photo] = [Photo]()
        
        for i in selectedIndexes {
            photosToDelete.append(fetchedResultsController.object(at: i))
        }
        
        for i in photosToDelete {
            dataController.viewContext.delete(i)
            try? dataController.viewContext.save()
        }
        
        selectedIndexes.removeAll()
        
      //  getPhotosFromFlickr(pin!)
    }
    
}


