//
//  Sight.m
//  CityGuide-ObjC-NoNib
//
//  Created by Roger Carvalho on 16/07/2015.
//  Copyright (c) 2015 RDC Media Ltd. All rights reserved.
//

#import "Sight.h"

@interface Sight ()

//Private properties, for use only within the object when processing data
@property(strong, atomic) NSMutableData *imageData;
@property() BOOL secondCall;
@end

@implementation Sight

- (id)initWithContent:(NSInteger)reference
             andName:(NSString*)name
         andShortDesc: (NSString*) shortDesc
         andLongDesc: (NSString*) longDesc
          andImageURL: (NSURL*)imageUrl
       andImageOnline: (BOOL)imageOnline
          andLocation: (CLLocationCoordinate2D)location
//Designated initializer: sets the public properties
{
    if ( self = [super init] )
    {
        self.reference = reference;
        self.name = name;
        self.shortDesc = shortDesc;
        self.longDesc = longDesc;
        self.imageOnline = imageOnline;
        self.imageUrl = imageUrl;
        self.location = location;

        return self;
        
    }
    
    else
    {
        return nil;
    }
    
}

-(void)downloadImage:(id)delegate toReference:(id)reference
//Downloads the image of the sight.
{
    //Determine whether to get the image from a URL or from the local package
    if (self.imageOnline)
    {
    
        if (self.imageDownloaded)
        //If the image was already downloaded previously, just provide the image property to the delegate
        {
            [delegate imageFinishedDownloading:self andImage:self.image toReference:reference];
        }
        else
        {
            //Set the local delegate and reference properties (to be used when the data has finished downloading)
            self.delegate = delegate;
            self.imageReference = reference;
        
            //Download the image
            NSURLRequest *request = [NSURLRequest requestWithURL:self.imageUrl];
            
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                if (connectionError)
                {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        NSLog(@"Error occurred: %@", connectionError.localizedDescription);
                    }];
                }
                else
                {
                    self.image = [[UIImage alloc] initWithData:data];
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        //Set the imageDownloaded flag to yes, so in the future we will know this image doesn't need to be downloaded again
                        self.imageDownloaded = YES;
                        
                        //Call the delegate method and provide it with the image data and the reference object that will show the image
                        [self.delegate imageFinishedDownloading:self andImage:self.image toReference:self.imageReference];


                    }];
                }
            }];
            
        }
    }
    else
    {
#warning The routine to load images from the local package is still to be defined.
    }
}
@end
