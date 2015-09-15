//
//  AppDelegate.h
//  CityGuide-ObjC-NoNib
//
//  Created by Roger Carvalho on 15/07/2015.
//  Copyright (c) 2015 RDC Media Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterViewController.h"
#import "ListViewController.h"
#import "DetailViewController.h"
#import "MapViewController.h"
#import "WebViewController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate,UISplitViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, atomic) MasterViewController *tabs;

@property (strong, atomic) UINavigationController *navTab;
@property (strong, atomic) UINavigationController *mapTab;
@property (strong, atomic) UINavigationController *webTab;

@property (strong, atomic) ListViewController *listView;
@property (strong, atomic) DetailViewController *detailView;
@property (strong, atomic) MapViewController *mapView;
@property (strong, atomic) WebViewController *webView;
@property (strong, atomic) UISplitViewController *iPadView;
@property () UIPopoverController *popoverController;


@end

