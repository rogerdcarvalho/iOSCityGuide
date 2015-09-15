//
//  MapViewController.m
//
//  Created by Roger Carvalho on 15/07/2015.
//  Copyright (c) 2015 RDC Media Ltd. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()
@property (strong, nonatomic) CLLocationManager *locationManager;
@property() UIImage *locationImage;
@property() UIButton *myLocationButton;
@property() BOOL sightsMarked;
@end

@implementation MapViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//Upon initialization, set the title and subscribe to the notifications
{
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] )
    {
        
        self.title = NSLocalizedString(@"MAP_TITLE", nil);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData:) name:@"DataReady" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectPin:) name:@"SelectPin" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navigateToSight) name:@"Navigate" object:nil];

        return self;
    }
    
    else
    {
        return nil;
    }
    
}
- (void)loadData:(NSNotification *)note
//When a notification is received, reference all sights in the local property
{
    
    NSDictionary *sights = [[note userInfo] valueForKey:@"Data"];
    self.sights =sights;

    if (self.isViewLoaded && self.view.window)
    {
        // viewController is visible
        [self markSights];
    }
    
}
- (void)viewDidLoad
//Prepare the map whenever the view loads
{
    [super viewDidLoad];
    
    //Get the screen dimensions
    CGFloat fullHeight = self.navigationController.view.superview.frame.size.height;
    CGFloat fullWidth = self.navigationController.view.superview.frame.size.width;
    CGFloat heightOffset = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;

    //Prepare a map view for the available screen real estate (full width and height reduced by the tabbar on the bottom (the top is drawn below the navigation title bar)
    CGRect mapFrame = CGRectMake(0, heightOffset, fullWidth, fullHeight - self.navigationController.tabBarController.tabBar.frame.size.height - heightOffset);
    self.cityMap = [[MKMapView alloc]initWithFrame:mapFrame];
    self.cityMap.delegate = self;
    
    //Set the map location to whatever area this app caters to (defined in Constansts.h)
    CLLocationCoordinate2D initialLocation = (CLLocationCoordinate2D){.latitude = BASE_LATITUDE, .longitude = BASE_LONGITUDE};
    CLLocationDistance regionRadius = BASE_RADIUS;
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation, regionRadius * 2.0, regionRadius * 2.0);
    self.cityMap.showsUserLocation = YES;

    //Show the map and move it to the region indicated above
    [self.view addSubview:self.cityMap];
    [self.cityMap setRegion:coordinateRegion animated:true];
   
    //Show the users location on the map
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    //Ask for permission to track the users location. Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    self.locationImage = [[UIImage imageNamed:@"location.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
    //Create a My Location button to help the user find his location
    {
   
        //Prepare a my location button
        
        self.myLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.myLocationButton setBackgroundImage:self.locationImage forState:UIControlStateNormal];
        self.myLocationButton.frame = CGRectMake(fullWidth - 48, fullHeight - self.navigationController.tabBarController.tabBar.frame.size.height - self.navigationController.navigationBar.frame.size.height - 24, 24.0, 24.0);
        [self.myLocationButton setImage:self.locationImage forState:UIControlStateNormal];
        self.myLocationButton.tintColor = [UIColor blackColor];
        
        [self.view addSubview:self.myLocationButton];
        [self.myLocationButton addTarget:self action:@selector(moveToCurrentLocation) forControlEvents:UIControlEventTouchUpInside];
        
        //Show the users location on the map
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
    
    }
    if (self.sights)
    {
        //Mark the sights
        [self markSights];
    }
    
}
- (void) viewDidAppear:(BOOL)animated
{
    //If the view was opened with the request to select a sight, do so
    if(self.selectedSight)
    {
        NSNumber *key = [NSNumber numberWithInt:self.selectedSight.reference];
        MapPin *sightPin = [self.sightPins objectForKey:key];
        [self.cityMap selectAnnotation:sightPin animated:YES];
        self.selectedSight = nil;
    }
    
    //Check if orientation has changed
    //Get the screen dimensions
    CGFloat fullHeight = self.navigationController.view.superview.frame.size.height;
    CGFloat fullWidth = self.navigationController.view.superview.frame.size.width;
    
    
    CGFloat heightOffset = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
    
    //Update the map frame
    CGRect mapFrame = CGRectMake(0, heightOffset, fullWidth, fullHeight - self.navigationController.tabBarController.tabBar.frame.size.height - heightOffset);
    self.cityMap.frame = mapFrame;
    
    self.myLocationButton.frame = CGRectMake(fullWidth - 48, fullHeight - self.navigationController.tabBarController.tabBar.frame.size.height - self.navigationController.navigationBar.frame.size.height - 24, 24.0, 24.0);
    


}
- (void) moveToCurrentLocation
//Moves the map to wherever the user is
{
    CLLocation *location = [self.locationManager location];
    CLLocationCoordinate2D myLocation;
    myLocation.longitude = location.coordinate.longitude;
    myLocation.latitude = location.coordinate.latitude;
    
    //Set the map location to current location
    CLLocationCoordinate2D myLocation2D = myLocation;
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionMakeWithDistance(myLocation2D, 0, 0);
    [self.cityMap setRegion:coordinateRegion animated:true];
    self.myLocationButton.tintColor =[UIColor blueColor];
}
- (void) markSights
//Marks all sights with pins on the map
{
    self.sightPins = [[NSMutableDictionary alloc] init];
    
    //Loop through all categories
    for (id key in self.sights)
    {
        NSDictionary* category = [self.sights objectForKey:key];
        NSDictionary* sights = [category objectForKey:@"items"];
        NSArray *keys = [sights allKeys];
        for (id key in keys)
        {
            Sight* sight = [sights objectForKey:key];
            //Pin the sight and add its reference, name and description
            NSString *categoryId = [category objectForKey:@"id"];
            //NSInteger categoryId = [categoryIdString integerValue];
            MapPin *sightPin = [[MapPin alloc]initWithCoordinates:sight.location placeName:sight.name description:sight.shortDesc placeId:sight.reference categoryId:categoryId];

            [self.cityMap addAnnotation:sightPin];
            
            //Add the pin to the local array property so other objects can link to it
            [self.sightPins setObject:sightPin forKey:key];

        }
        self.sightsMarked = YES;
    }
       
    if(self.selectedSight)
    //If the view was opened with the request to select a signt, do so
    {
        NSNumber *key = [NSNumber numberWithInt:self.selectedSight.reference];
        MapPin *sightPin = [self.sightPins objectForKey:key];
        [self.cityMap selectAnnotation:sightPin animated:YES];
        self.selectedSight = nil;
    }

}
-(void)navigateToSight
//Opens apple maps with a reference to the sight location
{
    //Get the coordinate
    CLLocationCoordinate2D coordinate = self.selectedSight.location;
    
    //Prepare a placemark and map item
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                   addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem setName:self.selectedSight.name];
    
    // Pass the map item to the Maps app
    [mapItem openInMapsWithLaunchOptions:nil];
}

-(void)selectPin:(NSNotification *)note
//Sets a given pin to be selected. It receives a sight, which it sets to be selected. The viewDidAppear or markSights methods will then ensure it becomes selected if the view isn't visible, otherwise this method will do it directly
{
    Sight *sight = [[note userInfo] valueForKey:@"Data"];
    self.selectedSight = sight;
    self.myLocationButton.tintColor =[UIColor blackColor];
    
    //Normally viewDidAppear will handle actually showing the selected sight. However, it could be that the view is already visible
    if (self.isViewLoaded && self.view.window)
    {
        NSNumber *key = [NSNumber numberWithInt:sight.reference];
        MapPin *sightPin = [self.sightPins objectForKey:key];
        [self.cityMap selectAnnotation:sightPin animated:YES];
        self.selectedSight = nil;
    }
    
}

#pragma mark Delegate Methods

- (void)showDetail:(Sight *)sight
//Opens a detailView with Sight information
{
    if IPHONE
    {
        //Push it to the navigation stack
        DetailViewController *vc = [[DetailViewController alloc] initWithNibName:nil bundle:nil andSight:sight];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if IPAD
    {
        //Open a modal view
        DetailViewController *viewController = [[DetailViewController alloc] initWithNibName:nil bundle:nil andSight:sight];
        viewController.delegate = self;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:navigationController animated:YES completion:nil];
        navigationController.view.superview.frame = CGRectMake(0, 0, 800, 544);
        navigationController.view.superview.center = self.view.center;
        
    }
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
//When the user taps on a pinned sight
{
    MapPin *pin = [view annotation];
    NSString *key = pin.categoryId;
    NSInteger reference = pin.placeId;
    
    //Set the selectedSight to the public property, so any object can find out
    NSDictionary *selectedCategory = [self.sights objectForKey:key];
    NSDictionary *sights = [selectedCategory objectForKey:@"items"];
    
    self.selectedSight = [sights objectForKey:[NSNumber numberWithInteger:reference] ];
    
    if (control.tag == 0)
    //The user pressed the info button, open a detailView
    {
        [self showDetail:self.selectedSight];

    }
    else
    //The user wants to navigate to the sight
    {
        //Open an alert to let the user confirm they want to leave the app
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NAVIGATION_TITLE", nil) message:NSLocalizedString(@"NAVIGATION_CONFIRMATION_TEXT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL_BUTTON", nil)otherButtonTitles:NSLocalizedString(@"OK_BUTTON", nil), nil];
        [alertView show];
    }
}

-(void)dismissModal:(DetailViewController *)view;
{
    [view dismissViewControllerAnimated:true completion:nil];

}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
//Layout the pin view, which will show once a user has selected a pin
{
    self.myLocationButton.tintColor =[UIColor blackColor];

    
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MapPin class]])
    {
        // Try to dequeue an existing pin view first.
       MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.canShowCallout = YES;
            pinView.calloutOffset = CGPointMake(0, 32);
            
            //Add a navigation button.
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [rightButton setBackgroundImage:self.locationImage forState:UIControlStateNormal];
            CGRect buttonSize = CGRectMake(0, 0, 24, 24);
            rightButton.frame = buttonSize;
            rightButton.tintColor = [UIColor blueColor];
            pinView.rightCalloutAccessoryView = rightButton;
            rightButton.tag = 1;

            //Add a detail disclosure button to the callout.
            UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            pinView.leftCalloutAccessoryView = leftButton;
            leftButton.tag = 0;
            leftButton.tintColor = [UIColor blueColor];
            
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
//When the user has indicated they do want to leave the app to navigate
{
    if (buttonIndex == 1)
    {
        [self navigateToSight];
    }
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //Get the screen dimensions
    CGFloat fullHeight = self.navigationController.view.superview.frame.size.height;
    CGFloat fullWidth = self.navigationController.view.superview.frame.size.width;

    
    CGFloat heightOffset = [UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height;
    
    //Update the map frame
    CGRect mapFrame = CGRectMake(0, heightOffset, fullWidth, fullHeight - self.navigationController.tabBarController.tabBar.frame.size.height - heightOffset);
    self.cityMap.frame = mapFrame;
    
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
    {
        //Update the my location button
        self.myLocationButton.frame = CGRectMake(fullWidth - 48, fullHeight - self.navigationController.tabBarController.tabBar.frame.size.height - self.navigationController.navigationBar.frame.size.height - 24, 24.0, 24.0);
    }
}
/*
Newer method for iOS 8, interesting to keep an eye on for future iterations
- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{ [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
    {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        // do whatever
    }
    completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
   {
    
   }]; [super viewWillTransitionToSize: size withTransitionCoordinator: coordinator];
}
*/



@end
