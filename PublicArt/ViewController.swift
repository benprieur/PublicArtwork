//
//  ViewController.swift
//  PublicArt
//
//  Created by Benoît Prieur on 06/05/2018.
//  Copyright © 2018 Soarthec. All rights reserved.
//`

import Foundation
import Mapbox
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, MGLMapViewDelegate {
    override func viewDidLoad() {
        
        
        let mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 40.189167 , longitude: 44.515278), zoomLevel: 18, animated: false)
        view.addSubview(mapView)
        
        
        // Add a point annotation
        let annotation = MGLPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 40.189167 , longitude: 44.515278)
        annotation.title = "Tamanyan Street"
        annotation.subtitle = "Թամանյան փողոց"
        //mapView.addAnnotation(annotation)
        
        // Allow the map view to display the user's location
        mapView.showsUserLocation = true
        
        // Get bounds
        let bounds = mapView.visibleCoordinateBounds
        let south:String = String(format:"%f", bounds.sw.latitude)
        let west:String = String(format:"%f", bounds.sw.longitude)
        let north:String = String(format:"%f", bounds.ne.latitude)
        let east:String = String(format:"%f", bounds.ne.longitude)
       
        // Make string http request
        let urlPath = "http://overpass-api.de/api/interpreter?data=[out:json];node[tourism=artwork]"
            + "("
            + south
            + ","
            + west
            + ","
            + north
            + ","
            + east
            + ");out%20body;"
        
        // request calling
        Alamofire.request(urlPath)
            .responseJSON { response in
                // check for errors
                guard response.result.error == nil else
                {
                    // got an error in getting the data, need to handle it
                    print("error calling")
                    print(response.result.error!)
                    return
                }
                
                // JSON
                let json = JSON(response.data)
                for item in json["elements"].arrayValue {
                    
                    // Data from OpenStreetMap
                    let latArtwork = item["lat"].double
                    let lonArtwork = item["lon"].double
                    let idOpenStreetMap = item["id"].stringValue
                    let tags = item["tags"]
                    let idWikidata = tags["wikidata"].stringValue
                    
                    let marker = MGLPointAnnotation()
                    marker.coordinate = CLLocationCoordinate2D(latitude: latArtwork!, longitude: lonArtwork!)
                    //marker.subtitle = "OpenStreetMap ID: " + idOpenStreetMap

                    // Data from Wikidata
                    if (idWikidata != "")
                    {
                       let urlWikidata = "https://www.wikidata.org/w/api.php?action=wbgetentities&ids=" + idWikidata + "&format=json"
                       Alamofire.request(urlWikidata)
                            .responseJSON { responseWikidata in
                                // check for errors
                                guard responseWikidata.result.error == nil else
                                {
                                    // got an error in getting the data, need to handle it
                                    print("error calling")
                                    print(responseWikidata.result.error!)
                                    return
                                }
                                
                                // JSON
                                let jsonWikidata = JSON(responseWikidata.data)
                                
                                let entities = jsonWikidata["entities"]
                                let entity = entities[idWikidata]

                                let labels = entity["labels"]
                                let label = labels["fr"]

                                let descriptions = entity["descriptions"]
                                let description = descriptions["fr"]

                                marker.title = label["value"].stringValue
                                marker.subtitle = description["value"].stringValue

                        }
                                
                    }
                    
                    mapView.addAnnotation(marker)
                    mapView.selectAnnotation(marker, animated: true)
                    
                }
                
                mapView.delegate = self
                
        }
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
}
