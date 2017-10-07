//
//  FlickrClient.swift
//  EuroFlipBook
//
//  Created by Stephen Martinez on 10/7/17.
//  Copyright © 2017 Stephen Martinez. All rights reserved.
//

import Foundation

class FlickrClient{
    
    private static func infoForPhotosAtLocation(
        latitude: String,
        longitude: String,
        completion: @escaping(_ totalPhotos: Int?, _ totalPages: Int?, _ error: NetworkError? )-> Void){
        let domain = "infoForPhotosAtLocation(:_)"
        let parameters = FlickrCnst.methodParametersWith(latitude, longitude)
        let request = URLRequest(url: FlickrCnst.URLwith(parameters))
        
        let task = EuroFlipBook.shared.session.dataTask(with: request){ data, response, error in
            guard (error == nil) else{return completion(nil, nil, NetworkError.general)}
            //Allow only OK status to continue
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299
                else{ return completion(nil, nil, NetworkError.nonOKHTTP(status: (response as! HTTPURLResponse).statusCode))}
            //Exit method if no data is present.
            guard let data = data else{return completion(nil, nil, NetworkError.noDataReturned(domain: domain))}
            //Convert the data into Swift's AnyObject Type
            let results = FlickrCnst.convertToSwift(with: data)
            //Exit the method if the conversion returns a conversion error
            guard let resultsObject = results.swiftObject as? [String : Any] else {return completion(nil, nil, results.error)}
            //Validate the expected object to be recieved as a dictionary
            guard let resultDictionary = resultsObject[FlickrCnst.ResponseKeys.Photos] as? [String: Any]
                else{return completion(nil, nil, NetworkError.invalidAPIPath(domain: domain))}
            //Validate that "total" and "pages" in the dictionary can be casted as an integer.
            //The "total" photos comes back as a string when deserialized from JSON! Need to further convert it into an Int.
            guard let numberOfPhotos = resultDictionary[FlickrCnst.ResponseKeys.Total] as? String, let numOfPhotos = Int(numberOfPhotos),
                let numOfPages = resultDictionary[FlickrCnst.ResponseKeys.Pages] as? Int else{
                    return completion(nil, nil, NetworkError.invalidAPIPath(domain: domain))
            }
            return completion(numOfPhotos, numOfPages, nil)
        }
        task.resume()
    }
    
    static func photosForLocation(
        latitude: String,
        longitude: String,
        completion: @escaping(_ photoList: [(thumbnail: URL, fullSize: URL, photoID: String)]?, _ error: NetworkError? )-> Void){
        
        infoForPhotosAtLocation(latitude: latitude, longitude: longitude){ totalPhotos, totalPages, error in
            guard (error == nil) else{ return completion(nil, error)}
            guard let photosReturned = totalPhotos, photosReturned != 0 else{return completion( [(URL, URL, String)](),nil)}
            guard let pagesReturned = totalPages, pagesReturned != 0 else{return completion( [(URL, URL, String)](),nil)}
            
            let photoInfo = FlickrCnst.randomPhotoSelections(
                photos: photosReturned,
                pages: pagesReturned,
                perPage: FlickrCnst.Prefered.PhotosPerPage)
            
            let pageNumber = String(photoInfo.pageNum)
            var photoIndexList = photoInfo.listIndex
            let domain = "photosForLocation(:_)"
            let parameters = FlickrCnst.methodParametersWith(latitude, longitude, pageNumber)
            let request = URLRequest(url: FlickrCnst.URLwith(parameters))
            
            let task = EuroFlipBook.shared.session.dataTask(with: request){ data, response, error in
                guard (error == nil) else{return completion(nil, NetworkError.general)}
                //Allow only OK status to continue
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299
                    else{ return completion(nil, NetworkError.nonOKHTTP(status: (response as! HTTPURLResponse).statusCode))}
                //Exit method if no data is present.
                guard let data = data else{return completion(nil, NetworkError.noDataReturned(domain: domain))}
                //Convert the data into Swift's AnyObject Type
                let results = FlickrCnst.convertToSwift(with: data)
                //Exit the method if the conversion returns a conversion error
                guard let resultsObject = results.swiftObject as? [String : Any] else {return completion(nil, results.error)}
                //Validate the expected object to be recieved as a dictionary
                guard let resultDictionary = resultsObject[FlickrCnst.ResponseKeys.Photos] as? [String: Any]
                    else{return completion(nil, NetworkError.invalidAPIPath(domain: domain))}
                //Validate the expected photo dictionary as a dictionary
                guard var photoDictionary = resultDictionary[FlickrCnst.ResponseKeys.Photo] as? [[String: Any]]
                    else{return completion(nil, NetworkError.invalidAPIPath(domain: domain))}
                
                //If the Flickr API gave us an amount of photos less than stated, adjust the indexList to reflect the status
                if photoDictionary.count < photoIndexList.count{
                    photoIndexList = FlickrCnst.indexListRand(photoDictionary.count)}
                //If there are more photos returned than stated, then remove the photos to reflect what was stated.
                if photoDictionary.count > photoIndexList.count{
                    while photoDictionary.count > photoIndexList.count{_ = photoDictionary.popLast()}}
                //Check that the expected photo count is the same as told by the Flickr API.
                guard photoIndexList.count == photoDictionary.count
                    else{return completion(nil, NetworkError.differentObject(
                        description: "Flickr API returned an unexpected amount of photos"))}
                
                var photosToReturn = [(thumbnail: URL, fullSize: URL, photoID: String)]()
                
                for indexer in photoIndexList{
                    let returnedPhoto = photoDictionary[indexer]
                    guard let thumbnailString = returnedPhoto[FlickrCnst.ResponseKeys.SquareURL] as? String,
                        let thumbnail = URL(string: thumbnailString),
                        let fullImageString = returnedPhoto[FlickrCnst.ResponseKeys.MediumURL] as? String,
                        let fullImage = URL(string: fullImageString),
                        let photoID = returnedPhoto[FlickrCnst.ResponseKeys.PhotoID] as? String
                        else{ print("Photo excluded during the loop is \(photoDictionary[indexer])"); continue}
                    photosToReturn.append((thumbnail: thumbnail, fullSize: fullImage, photoID: photoID))
                }
                return completion(photosToReturn, nil)
            }
            task.resume()
        }
    }
    
    static func getPhotoFor(thumbnailURL: URL, fullSizeURL: URL,completion:
        @escaping(_ images: (thumbnail: Data?, fullSize: Data?)?, _ error: NetworkError?) -> Void  ){
        let domain = "getPhotoFor(:_)"
        let taskOne = EuroFlipBook.shared.session.dataTask(with: thumbnailURL){ data, response, error in
            guard (error == nil) else{return completion(nil, NetworkError.general)}
            //Allow only OK status to continue
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299
                else{ return completion(nil, NetworkError.nonOKHTTP(status: (response as! HTTPURLResponse).statusCode))}
            //Exit method if no data is present.
            guard let data = data else{return completion(nil, NetworkError.noDataReturned(domain: domain))}
            //Convert the data into Swift's AnyObject Type
            let thumbnailPhoto = data
            //Now that we have the thumbnail image data, lets get the image data for the full image
            let taskTwo = EuroFlipBook.shared.session.dataTask(with: fullSizeURL){ data, response, error in
                guard (error == nil) else{return completion(nil, NetworkError.general)}
                //Allow only OK status to continue
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299
                    else{ return completion(nil, NetworkError.nonOKHTTP(status: (response as! HTTPURLResponse).statusCode))}
                //Exit method if no data is present.
                guard let data = data else{return completion(nil, NetworkError.noDataReturned(domain: domain))}
                //Convert the data into Swift's AnyObject Type
                let fullSizePhoto = data
                //Send the results back through the completion handler.
                return completion((thumbnailPhoto, fullSizePhoto), nil)
            }
            taskTwo.resume()
        }
        taskOne.resume()
    }
    
    static func getPhotoFor(url: URL, completion: @escaping(_ image: Data?, _ error: NetworkError?) -> Void  ){
        let domain = "getPhotoFor(:_)"
        let task = EuroFlipBook.shared.session.dataTask(with: url){ data, response, error in
            guard (error == nil) else{return completion(nil, NetworkError.general)}
            //Allow only OK status to continue
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299
                else{ return completion(nil, NetworkError.nonOKHTTP(status: (response as! HTTPURLResponse).statusCode))}
            //Exit method if no data is present.
            guard let data = data else{return completion(nil, NetworkError.noDataReturned(domain: domain))}
            //Send the image data through the completion handler
            return completion(data, nil)
        }
        task.resume()
    }
    
}






struct FlickrCnst {
    struct Prefered {
        static let PhotosPerPage = 10
        private init(){}
    }
    
    struct API {
        static let Scheme = "https"
        static let Host = "api.flickr.com"
        static let Path = "/services/rest"
        private init (){}
    }
    
    struct ParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Page = "page"
        static let PerPage = "per_page"
        static let Radius = "radius"
        static let UnitOfMeasure = "radius_units"
        static let ContentType = "content_type"
        static let Latitude = "lat"
        static let Longitude = "lon"
        private init (){}
    }
    
    struct ParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "9215bde1ab1104b17d0008d70ddf92c4"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = JSONCallback.Yes
        static let MediumURL = "url_z"
        static let SquareURL = "url_q"
        static let ExtrasList = extrasList(ParameterValues.MediumURL, ParameterValues.SquareURL)
        static let UseSafeSearch = SafeSearch.Safe
        static let Radius = "10"
        static let Miles = "mi"
        static let PhotosOnly = "1"
        static let PhotosPerPage = "\(Prefered.PhotosPerPage)"
        static func extrasList(_ extras: String...)-> String{return extras.joined(separator: ",")}
        private init (){}
    }
    
    struct ResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_z"
        static let SquareURL = "url_q"
        static let Pages = "pages"
        static let Total = "total"
        static let PhotoID = "id"
        private init (){}
    }
    
    struct ResponseValues {
        static let statusOK = "ok"
        static let statusFail = "fail"
        private init (){}
    }
    
    struct JSONCallback {
        static let No = "0"
        static let Yes = "1"
        private init (){}
    }
    
    struct SafeSearch {
        static let Safe = "1"
        static let Moderate = "2"
        static let Restricted = "3"
        private init (){}
    }
    
    static func URLwith(_ parameters: [String: Any]) -> URL {
        var components = URLComponents()
        components.scheme = FlickrCnst.API.Scheme
        components.host = FlickrCnst.API.Host
        components.path = FlickrCnst.API.Path
        components.queryItems = [URLQueryItem]()
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.url!
    }
    
    static func methodParametersWith(_ lat: String, _ lon: String, _ withPage: String? = nil ) -> [String : Any] {
        var methodParameters: [String: Any] = [
            FlickrCnst.ParameterKeys.Method : FlickrCnst.ParameterValues.SearchMethod,
            FlickrCnst.ParameterKeys.APIKey : FlickrCnst.ParameterValues.APIKey,
            FlickrCnst.ParameterKeys.Format : FlickrCnst.ParameterValues.ResponseFormat,
            FlickrCnst.ParameterKeys.NoJSONCallback : FlickrCnst.ParameterValues.DisableJSONCallback,
            FlickrCnst.ParameterKeys.Latitude : lat,
            FlickrCnst.ParameterKeys.Longitude : lon,
            FlickrCnst.ParameterKeys.Radius : FlickrCnst.ParameterValues.Radius,
            FlickrCnst.ParameterKeys.UnitOfMeasure : FlickrCnst.ParameterValues.Miles,
            FlickrCnst.ParameterKeys.ContentType : FlickrCnst.ParameterValues.PhotosOnly,
            FlickrCnst.ParameterKeys.SafeSearch : FlickrCnst.ParameterValues.UseSafeSearch,
            FlickrCnst.ParameterKeys.PerPage : FlickrCnst.ParameterValues.PhotosPerPage,
            FlickrCnst.ParameterKeys.Extras : FlickrCnst.ParameterValues.ExtrasList
        ]
        if let pageNumber = withPage{methodParameters[FlickrCnst.ParameterKeys.Page] = pageNumber}
        return methodParameters
    }
    
    //Use this method to create a random page number
    static func pageNoRand(_ pages: Int) -> Int{
        let firstTry = pages == 0 ? 0 : Int(arc4random_uniform(UInt32(pages))) + 1
        let Second = pages == 0 ? 0 : Int(arc4random_uniform(UInt32(pages))) + 1
        return min(firstTry, Second)
    }
    
    //Use this method to create a list of random indexing integers
    static func indexListRand(_ countOfList: Int) -> [Int]{
        guard (countOfList != 0) else{return [Int]()}
        var indexList = [Int](); var remainingList = Array(0..<countOfList)
        var indexer: Int{get{return Int(arc4random_uniform(UInt32(remainingList.count)))}}
        for _ in 1...countOfList{
            let index = indexer
            let indexToEnter = remainingList[index]
            remainingList.remove(at: index)
            indexList.append(indexToEnter)
        }
        return indexList
    }
    
    //Use this method to Select a Random Page and Index List based on results returned from the Server
    //This method limits the listIndex by the perPage Amount in order to prevent errors.
    static func randomPhotoSelections(photos: Int, pages: Int, perPage: Int) -> (pageNum: Int, listIndex: [Int]){
        guard pages != 0,  pages ==  (((photos - (photos % perPage)) / perPage) + 1), perPage != 0 else{return (0, [])}
        switch photos {
        case let x where x < perPage: return (1, indexListRand(x))
        case let x where x > 4000:
            let newPages = 4000/perPage
            return (pageNoRand(newPages),indexListRand(perPage))
        case let x where x > perPage && (x % perPage) != 0:
            let removedLastPage = pages - 1
            return (pageNoRand(removedLastPage),indexListRand(perPage))
        case let x where x > perPage && (x % perPage) == 0:
            return (pageNoRand(pages), indexListRand(perPage))
        default: return (0,[])
        }
    }
    
    //Use This Method when sending Data to a server
    static func convertToJSON(with object: AnyObject) -> (JSONObject: Data?, error: NetworkError?){
        var wouldBeJSON: Data? = nil
        do{ wouldBeJSON = try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)}
        catch{return (wouldBeJSON, NetworkError.JSONToData)}
        return (wouldBeJSON, nil)
    }
    
    //Use this Method when recieving Data from a server
    static func convertToSwift(with JSON: Data) -> (swiftObject: AnyObject?, error: NetworkError?){
        var wouldBeSwift: AnyObject? = nil
        do{ wouldBeSwift = try JSONSerialization.jsonObject(with: JSON, options: .allowFragments) as AnyObject}
        catch{return (wouldBeSwift, NetworkError.DataToJSON)}
        return (wouldBeSwift, nil)
    }
    
    private init (){}
}





