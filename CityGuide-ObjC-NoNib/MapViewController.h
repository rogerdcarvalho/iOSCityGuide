//
//  MapViewController.h
//
//  Created by Roger Carvalho on 15/07/2015.
//  Copyright (c) 2015 RDC Media Ltd. All rights reserved.
//
/*
 
 This view controller handles a map of sights. It shows a map of the city that contains the sight, with pins on all the sights loaded.
 
 The designated initializer is:
 
 -(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
 
 It will wait for a notification containing an NSDictionary of sights from a sightsDatabase, and then use this to build the pins of the sights. Each sight is clickable and will open a detailView with its full information, or allow the user to navigate there via Apple Maps
 */

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "SightsDatabase.h"
#import "MapPin.h"
#import "DetailViewController.h"

@interface MapViewController : UIViewController<CLLocationManagerDelegate,MKMapViewDelegate, UIAlertViewDelegate, DetailViewControllerDelegate>

//Public properties: Any object can see the list of sights shown and access the map and which sight the user has selected
@property() NSMutableDictionary *sightPins;
@property() NSDictionary *sights;
@property() MKMapView *cityMap;
@property () Sight *selectedSight;

@end
