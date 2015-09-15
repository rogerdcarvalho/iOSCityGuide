//
//  ListViewController.h
//
//  Created by Roger Carvalho on 15/07/2015.
//  Copyright (c) 2015 RDC Media Ltd. All rights reserved.
//
/*
 
 This view controller handles a tableview of sights. It shows the name and the short description of a given sight and is meant to be viewed full screen on a tabbed application, within a UINavigationController hierarchy.
 
 The designated initializer is:
 
 -(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
 
 It will wait for a notification containing an NSDictionary of sights from a sightsDatabase, and then use this to build a list of sights. Each sight is clickable and will open a detailView with its full information
 
 */

#import <UIKit/UIKit.h>
#import "SightsDatabase.h"
#import "DetailViewController.h"

@interface ListViewController : UITableViewController

//Public properties, any object can request the list of sights currently shown, and the sequence in which they are shown in the tableView
@property() NSMutableArray *sightsCategoryReferences; //The references of each category in the sequence they appear
@property() NSDictionary *sights; //The full sight objects

@end
