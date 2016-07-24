//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Damonique Thomas on 7/20/16.
//  Copyright © 2016 Damonique Thomas. All rights reserved.
//

import Foundation

extension FlickrClient {

    struct Constants {
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest"
    }
    
    struct ParameterKeys {
        static let Method = "method"
        static let Lat = "lat"
        static let Lng = "lon"
        static let Page = "page"
        static let Extras = "extras"
        static let Format = "format"
        static let APIKey = "api_key"
        static let NoJSONCallback = "nojsoncallback"
    }
    
    struct ParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "5b924149ea8b3022e84492a7b5ccffb4"
        static let Format = "json"
        static let JSONCallback = "1"
        static let ExtraValue = "url_m"
    }
    
    struct ResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
    }
}


//"https://api.flickr.com/services/rest/
//?method=flickr.photos.search
//&api_key=4471ecc1512fb9ab0f48aa1e1d0eb9ee
//&lat=44.977753
//&extras=url_m
//&per_page=50
//&page=4
//&lon=-93.265011
//&format=json
//&nojsoncallback=1
