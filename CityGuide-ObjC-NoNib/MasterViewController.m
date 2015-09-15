//
//  MasterView.m
//  CityGuide-ObjC-NoNib
//
//  Created by Roger Carvalho on 16/07/2015.
//  Copyright (c) 2015 RDC Media Ltd. All rights reserved.
//

#import "MasterViewController.h"

@interface MasterViewController ()

@end

@implementation MasterViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //Keep track of when any other view wants to switch to the map
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showInMap:) name:@"LaunchMap" object:nil];

}
-(void)viewDidAppear:(BOOL)animated
{
    //Load up a sightsDatabase.
    self.sightsDBObject = [[SightsDatabase alloc]initWithDelegate:self];

}

-(BOOL)sightsShouldLoadInMemory:(SightsDatabase *)database
//For this version, the sightsDatabase will load in memory
{
    return true;
}
-(void)sightsDatabaseFinishedLoading:(SightsDatabase *)database withData:(NSDictionary *)data
{
    //Fill the local dictionary with all sights data
    self.sights = data;
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:data forKey:@"Data"];

    
    //Notify all views
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DataReady" object:nil userInfo:dictionary];
    
}

//Propogate navigationController events to the ViewControllers

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //[viewController viewWillAppear:animated];

}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
#warning don't do this
 //   [viewController viewDidAppear:animated];
}

#pragma mark helper methods
-(void)showInMap:(NSNotification *)note
//Switch to map view and post notification to select the pin
{
    //Receive the location that needs to be selected
    Sight *sight = [[note userInfo] valueForKey:@"Data"];
    
    if IPHONE
    {
        //Map view is the second view
        self.selectedIndex = 1;
    }
    else
    {
        //Map view is the first view
        self.selectedIndex = 0;
    }
    //Notify the map view that it needs to select a pin
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:sight forKey:@"Data"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectPin" object:nil userInfo:dictionary];
}




@end
