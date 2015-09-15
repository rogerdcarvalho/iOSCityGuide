//
//  Sight.h
//  CityGuide-ObjC-NoNib
//
//  Created by Roger Carvalho on 16/07/2015.
//  Copyright (c) 2015 RDC Media Ltd. All rights reserved.
//
/*
The Sight Class handles objects that contain information about tourist sights. You should initiate a sight using the designated initializer:
 
 - (id)initWithContent:(NSInteger)reference - The reference the sight can be identified with
 andName:(NSString*)name - The sight name
 andShortDesc: (NSString*) shortDesc - A short description of the sight
 andLongDesc: (NSString*) longDesc - A detailed description of the sight
 andImageURL: (NSURL*)imageUrl - Where the sight image can be downloaded from
 andImageOnline: (BOOL)imageOnline - Whether or not the image for this sight should be downloaded from the web or obtained from the local package
 andLocation: (CLLocationCoordinate2D)location; - The latitude and longitude of the sight

 When a sight is initialized, it does not yet contain an image (to ensure it loads quickly). When you want to display the sight in a view, call:

 -(void)downloadImage:(id)delegate toReference:(id)reference

Always call this method, whether the image is contained in the package or whether it is online. The method will ensure it will find it in the right location. The caller should send itself as delegate, and can optionally provide an object that will serve as a reference on how/where to place the image once it is ready. When the image is fully downloaded and/or processed, it will call the delegate method:

 -(void)imageFinishedDownloading:(Sight*)sight andImage:(UIImage*)image toReference:(id)reference;
 
*/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

//Let the compiler know how to process the protocol definition.
@class Sight;

//Any caller of 'downloadImage:(id)delegate toReference:(id)reference' should implement the SightViewer protocol.
@protocol SightViewer <NSObject>

@required
-(void)imageFinishedDownloading:(Sight*)sight andImage:(UIImage*)image toReference:(id)reference;
//This method will be called on the delegate object once the image has finished processing
@end

//This class implements the NSURLConnectionDataDelegate protocol to handle image downloads
@interface Sight : NSObject

//Public properties. Any object can access these to change the specifics of the sight, but be careful to ensure that the reference ID is aligned with any other data that is linked to the sight (such as images contained in the package)
@property() NSInteger reference;
@property() NSString *name;
@property() NSString *shortDesc;
@property() NSString *longDesc;
@property() NSURL *imageUrl;
@property() BOOL imageOnline;
@property() BOOL imageDownloaded;
@property() UIImage *image;
@property() CLLocationCoordinate2D location;
@property() id<SightViewer> delegate;
@property() id imageReference;

//Designated initializer
- (id)initWithContent:(NSInteger)reference
              andName:(NSString*)name
         andShortDesc: (NSString*) shortDesc
          andLongDesc: (NSString*) longDesc
          andImageURL: (NSURL*)imageUrl
       andImageOnline: (BOOL)imageOnline
          andLocation: (CLLocationCoordinate2D)location;

//Public methods
- (void)downloadImage:(id)delegate toReference:(id)reference;

@end
