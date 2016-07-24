//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Damonique Thomas on 7/20/16.
//  Copyright © 2016 Damonique Thomas. All rights reserved.
//

import Foundation

class FlickrClient {
    
    var session = NSURLSession.sharedSession()
    
    private var parameters = [ParameterKeys.APIKey:ParameterValues.APIKey, ParameterKeys.Method:ParameterValues.SearchMethod, ParameterKeys.Extras:ParameterValues.ExtraValue, ParameterKeys.Format:ParameterValues.Format, ParameterKeys.NoJSONCallback:ParameterValues.JSONCallback]
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    
    //Get photos from lat/long
    func getLocationPhotos(lat: Float, lng: Float, completionHandler: (photos: [String]?, success: Bool, error: String?) -> Void) {
        
        let session = NSURLSession.sharedSession()
        parameters[ParameterKeys.Lat] = "\(lat)"
        parameters[ParameterKeys.Lng] = "\(lng)"
        let request = NSURLRequest(URL: flickrURLFromParameters(parameters))
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                completionHandler(photos: nil, success: false, error: error)
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                sendError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let photosDictionary = parsedResult[ResponseKeys.Photos] as? [String:AnyObject] else {
                sendError("Cannot find keys '\(ResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            guard let totalPages = photosDictionary[ResponseKeys.Pages] as? Int else {
                sendError("Cannot find key '\(ResponseKeys.Pages)' in \(photosDictionary)")
                return
            }
            
            let pageLimit = min(totalPages, 40)
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1

            self.getPagePhotos(lat, lng: lng, page: randomPage, completionHandler: completionHandler)
        }
        
        task.resume()
    }
    
    private func getPagePhotos(lat: Float, lng: Float, page: Int, completionHandler: (photos: [String]?, success: Bool, error: String?) -> Void) {
        
        let session = NSURLSession.sharedSession()
        parameters[ParameterKeys.Lat] = "\(lat)"
        parameters[ParameterKeys.Lng] = "\(lng)"
        parameters[ParameterKeys.Page] = "\(page)"
        let request = NSURLRequest(URL: flickrURLFromParameters(parameters))
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                completionHandler(photos: nil, success: false, error: error)
            }
            
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                sendError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let photosDictionary = parsedResult[ResponseKeys.Photos] as? [String:AnyObject] else {
                sendError("Cannot find keys '\(ResponseKeys.Photos)' in \(parsedResult)")
                return
            }
            
            guard let total = photosDictionary[ResponseKeys.Total] as? Int else {
                sendError("Cannot find key '\(ResponseKeys.Total)' in \(photosDictionary)")
                return
            }
            
            guard let photo = photosDictionary[ResponseKeys.Photo] as? [[String:AnyObject]] else {
                sendError("Cannot find key '\(ResponseKeys.Photo)' in \(photosDictionary)")
                return
            }
            let photUrl = self.getRandomPhotos(total, photos: photo)
            completionHandler(photos: photUrl, success: true, error: nil)
        }
        
        task.resume()
    }

    
    func getPhoto(photoURL: String, completionHandler:(imageData: NSData?, success: Bool)->Void) {
        let url = NSURL(string: photoURL)
        if let imageData = NSData(contentsOfURL: url!) {
            completionHandler(imageData: imageData, success: true)
        }
        else {
            completionHandler(imageData: nil, success: false)
        }
    }
    
    private func getRandomPhotos (total: Int, photos: [[String:AnyObject]]) -> [String]{
        var chosen = [Int]()
        var randomPhotos = [String]()
        let perPage = min(total, 100)
        for _ in 0...12 {
            var random = Int(arc4random_uniform(UInt32(perPage)))
            while !chosen.contains(random) {
                random = Int(arc4random_uniform(UInt32(perPage)))
            }
            chosen.append(random)
            let photo = photos[random] as [String:AnyObject]
            if let photoUrl = photo[ResponseKeys.MediumURL] as? String {
                randomPhotos.append(photoUrl)
            }
        }
        return randomPhotos
    }
    
    
    private func flickrURLFromParameters(parameters: [String:AnyObject]) -> NSURL {
        let components = NSURLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.URL!
    }
}