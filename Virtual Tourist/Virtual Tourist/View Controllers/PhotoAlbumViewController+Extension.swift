//
//  PhotoAlbumViewController+Extension.swift
//  Virtual Tourist
//
//  Created by makramia on 26/01/2019.
//  Copyright © 2019 makramia. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sectionInfo = self.fetchedResultsController.sections?[section]{
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrPhotoViewCell", for: indexPath ) as! FlickrPhotoViewCell
        
        cell.imageView.image = nil
        cell.activityIndicator.startAnimating()
         deleteButton.isEnabled = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = fetchedResultsController.object(at: indexPath)
        let photoViewCell = cell as! FlickrPhotoViewCell
        photoViewCell.imageUrl = photo.imageUrl!
        configureCell(photoViewCell, photo: photo, collectionView: collectionView, index: indexPath)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedIndexes.append(indexPath)
        deleteButton.setTitle("Remove Selected Pictures", for: .normal)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        selectedIndexes.remove(at: indexPath.startIndex)
        
        if selectedIndexes.count == 0 {
            deleteButton.setTitle("New Collection", for: .normal)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying: UICollectionViewCell, forItemAt: IndexPath) {
        
        if collectionView.cellForItem(at: forItemAt) == nil {
            return
        }
        
        let photo = fetchedResultsController.object(at: forItemAt)
        if let imageUrl = photo.imageUrl {
             FlickrClient.sharedInstance().cancelDownload(imageUrl)
        }
    }
    
    private func configureCell(_ cell: FlickrPhotoViewCell, photo: Photo, collectionView: UICollectionView, index: IndexPath) {
        if let imageData = photo.image {
            cell.activityIndicator.stopAnimating()
            cell.imageView.image = UIImage(data: Data(referencing: imageData as NSData))
        } else {
            if let imageUrl = photo.imageUrl {
                cell.activityIndicator.startAnimating()
                FlickrClient.sharedInstance().downloadImage(imageUrl: imageUrl) { (data, error) in
                    if let _ = error {
                        self.performUIUpdatesOnMain {
                            cell.activityIndicator.stopAnimating()
                            //self.errorForImageUrl(imageUrl)
                            
                            print("Error: \(error!.localizedDescription)")
                        }
                        return
                    } else if let data = data {
                        self.performUIUpdatesOnMain {
                            
                            if let currentCell = collectionView.cellForItem(at: index) as? FlickrPhotoViewCell {
                                if currentCell.imageUrl == imageUrl {
                                    currentCell.imageView.image = UIImage(data: data)
                                    cell.activityIndicator.stopAnimating()
                                }
                            }
                            photo.image = data //NSData(data: data) as Data
                            DispatchQueue.global(qos: .background).async {
                            
                                try?self.dataController.viewContext.save()
                                 
                            }
                        }
                    }
                }
            }
        }
    }
  
    
}

extension PhotoAlbumViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
            
        }
        else {
            annotationView!.annotation = annotation
        }
        
        
        
        return annotationView
    }
}

//Mark : CoreData FetchedResultsController
extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
        
        switch (type) {
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .update:
            updatedIndexPaths.append(indexPath!)
            break
        case .move:
            print("Move item is not expected")
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItems(at: [indexPath])
            }
            
        }, completion: nil)
    }
    
}
