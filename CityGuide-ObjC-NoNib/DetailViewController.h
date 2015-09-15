//
//  DetailViewController.h
//
//  Created by Roger Carvalho on 15/07/2015.
//  Copyright (c) 2015 RDC Media Ltd. All rights reserved.
//
/*
 
This view controller handles a detailed view of Sights. It shows all relevant information of a given sight and is meant to be viewed full screen on a tabbed application (within a UINavigationController hierarchy) or within a Modal view on iPad.
 
The designated initializer is:
 
 -(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andSight:(Sight *)sight;

It will get all required information from the sight provided. The sight provided does not need to have an image yet, this viewcontroller will request to download the image before trying to display it.
 
*/

#import <UIKit/UIKit.h>
#import "SightsDatabase.h"

//Let the compiler know how to process the protocol definition.
@class DetailViewController;

//Declare the protocol any delegate of this object needs to implement
@protocol DetailViewControllerDelegate <NSObject>

@required
-(void)dismissModal:(DetailViewController *)view;
//This is used to close a modal view on iPad
@end

@interface DetailViewController : UIViewController

//Public property: Any other object can get details of the sight that is being displayed
@property() Sight *sight;
@property() id<DetailViewControllerDelegate> delegate;

//Designated initializer
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andSight:(Sight *)sight;
@end
