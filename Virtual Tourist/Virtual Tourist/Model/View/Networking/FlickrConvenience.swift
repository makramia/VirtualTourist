//
//  FlickrConvenience.swift
//  Virtual Tourist
//
//  Created by makramia on 26/01/2019.
//  Copyright © 2019 makramia. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    
    
    func searchPhotosFormFlickerBy(latitude:Double ,longitude:Double,totalPages: Int?, _ completionHandlerForFlickerPhoto: @escaping (_ success: Bool,_ photoData: Any?, _ errorString: String?) -> Void) {
        
        
        // get random page.
        var page: Int {
            if let totalPages = totalPages {
                let page = min(totalPages, 4000/FlickrParameterValues.PhotosPerPage)
                return Int(arc4random_uniform(UInt32(page)) + 1)
            }
            return 1
        }
        
        let bBox = self.bboxString(latitude: latitude, longitude: longitude)
        
        let parameters = [
            FlickrClient.FlickrParameterKeys.Method           : FlickrClient.FlickrParameterValues.SearchMethod
            , FlickrClient.FlickrParameterKeys.APIKey         : FlickrClient.FlickrParameterValues.APIKey
            , FlickrClient.FlickrParameterKeys.Format         : FlickrClient.FlickrParameterValues.ResponseFormat
            , FlickrClient.FlickrParameterKeys.Extras         : FlickrClient.FlickrParameterValues.MediumURL
            , FlickrClient.FlickrParameterKeys.NoJSONCallback : FlickrClient.FlickrParameterValues.DisableJSONCallback
            , FlickrClient.FlickrParameterKeys.SafeSearch     : FlickrClient.FlickrParameterValues.UseSafeSearch
            , FlickrClient.FlickrParameterKeys.BoundingBox    : bBox
            , FlickrClient.FlickrParameterKeys.PhotosPerPage  : FlickrClient.FlickrParameterValues.PhotosPerPage
            , FlickrParameterKeys.Page           : "\(page)"
            ] as [String : Any]
        
        /* 2. Make the request */
        
        _ = taskForGETMethod( parameters: parameters as [String : AnyObject] , decode: Response.self) { (result, error) in
            
            
            if let error = error {
                
                completionHandlerForFlickerPhoto(false ,nil,"\(error.localizedDescription)")
            }else {
                
                let newResult = result as! Response
                
                let resultData = newResult.photos!.photo
                
                if newResult.photos!.photo.isEmpty {
                    
                    
                    
                    completionHandlerForFlickerPhoto(true, nil, nil)
                    
                } else {
                   
                     completionHandlerForFlickerPhoto(true ,newResult, nil)
                }
                
                
                
                
            }
        }
        
    }
    
    
    
    
    
}
