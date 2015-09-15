//
//  MasterView.h
//  CityGuide-ObjC-NoNib
//
//  Created by Roger Carvalho on 16/07/2015.
//  Copyright (c) 2015 RDC Media Ltd. All rights reserved.
//
/*
 
 This view controller handles core navigation events and loads up the sightsDatabase. It is called directly by the appdelegate.
 */

#import <UIKit/UIKit.h>
#import "SightsDatabase.h"
#import "MapViewController.h"


@interface MasterViewController : UITabBarController<SightsDatabaseDelegate,UINavigationControllerDelegate>

//Public properties
@property() SightsDatabase *sightsDBObject;
@property() NSDictionary *sights;
@property() UINavigationController *navController;

//SightDatabase Delegate methods
-(BOOL)sightsShouldLoadInMemory:(SightsDatabase *)database;
-(void)sightsDatabaseFinishedLoading:(SightsDatabase *)database withData:(NSDictionary *)data;

//UINavigationController Delegate Methods
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end
