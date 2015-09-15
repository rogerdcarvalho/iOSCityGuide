//
//  SightsDatabase.m
//  CityGuide-ObjC-NoNib
//
//  Created by Roger Carvalho on 16/07/2015.
//  Copyright (c) 2015 RDC Media Ltd. All rights reserved.
//

#import "SightsDatabase.h"

@interface SightsDatabase ()
//Private properties - only used internally
@property NSString *downloadUrl;
@property() NSMutableData *json;
@property() NSURLConnection *connection;
@property() BOOL completeDictionary;
@property() BOOL onlineSource;
@property() NSMutableDictionary *sights;

@end

@implementation SightsDatabase

- (id)initWithDelegate:(id)delegate
//Upon initialization, set the default url where to get the collection data from and start downloading data
{
    self = [super init];
    if (self)
    {
        self.delegate = delegate;
        self.sights = [[NSMutableDictionary alloc] init];
        self.downloadUrl = @"JSON_URL";
        self.completeDictionary = NO;

#ifdef JSON_LOCATION_ONLINE

        self.onlineSource = YES;
        [self downloadData];
        
#endif
        
#ifdef JSON_LOCATION_LOCAL

#warning As the current package doesn't contain images, but does contain a local JSON, the private property onlineSource is still set to YES, which will cause sight objects to download the images from an online source.

        self.onlineSource = YES;
        [self importLocalData];
#endif
    
    }
    return self;
}


-(void)downloadData
//Downloads data from a remote server
{
    //In case of running from memory, clear any existing collection and set the flag to let other objects know the dictionary is not ready for use
    if ([self.delegate sightsShouldLoadInMemory:self])
    {
        self.completeDictionary = NO;
        [self.sights removeAllObjects];
    }
    
    //Setup connection and start downloading
    NSURL *url = [NSURL URLWithString:self.downloadUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}
-(void)importLocalData
//This method loads a JSON object stored in the project structure
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sights" ofType:@"json"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSData *json = [content dataUsingEncoding:NSUTF8StringEncoding];
    [self parseJson:json];
}

-(BOOL)isCompleteDatabase
//This method lets other objects know whether or not the database is complete. It will only return true if all sights have been correctly processed
{
    return self.completeDictionary;
}
-(void)parseJson:(NSData *)json
//This method processes JSON data to Sight objects. These objects can either be stored in memory using a NSDictionary, or can be provided on a record by record basis to the delegate for processing
{
    NSError *e = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: json options: NSJSONReadingMutableContainers error: &e];
    
    if (!jsonArray)
    {
        NSLog(@"Error parsing JSON: %@", e);
    }
    else
    {
        if ([self.delegate sightsShouldLoadInMemory:self])
        //Load all sights in a Dictionary object and provide this to the delegate
        {
            //Check if the required delegate method was implemented
            if ([self.delegate respondsToSelector:
                 @selector(sightsDatabaseFinishedLoading:withData:)])
            {
                //Loop through each item in the JSON array
                for(NSDictionary *item in jsonArray)
                {
                    //Create a dictionary of Categories in the sights property
                    [self.sights setObject:item forKey:[item objectForKey:@"id"]];
                    
                }
                
                //For each category, convert the data contained into Sight objects
                for(id categories in self.sights)
                {
                    NSMutableDictionary *category = [self.sights objectForKey:categories];
                    
                    //The actual Sight data is contained under the key "items", but in the wrong format (a NSArray containing NSDictionaries)
                    NSArray *sights = [category objectForKey:@"items"];
                    
                    //Create a new NSDictionary that will hold all Sights objects under "items"
                    NSMutableDictionary *sightObjects = [[NSMutableDictionary alloc]init];
                    
                    //Convert each existing item to a Sight object
                    for(NSDictionary *sight in sights)

                    {
                        //Prepare data
                        NSString *reference = sight[@"id"];
                        NSInteger referenceInt = [reference integerValue];
                        NSString *name = sight[@"name"];
                        NSString *shortDesc = sight[@"shortDesc"];
                        NSString *longDesc = sight[@"longDesc"];
                        NSURL *imageUrl =[NSURL URLWithString:sight[@"image"]];
                        
                        CLLocationCoordinate2D location;
                        location.latitude = [sight[@"lat"] doubleValue];
                        location.longitude =[sight[@"long"] doubleValue];
                        
                        //Create Sight object within the local property
                        Sight *sightObject = [[Sight alloc] initWithContent:referenceInt
                                                              andName: name
                                                         andShortDesc: shortDesc
                                                          andLongDesc: longDesc
                                                          andImageURL: imageUrl
                                                       andImageOnline: self.onlineSource
                                                          andLocation: location];
                        
                        
                        [sightObjects setObject:sightObject forKey:[NSNumber numberWithInt:referenceInt]];
                    }
                    
                    //Replace the NSArray under "items" with the new Dictionary
                    [category setObject:sightObjects forKey:@"items"];
                    
                }
                
                //We now have an NSDictionary of categories, each containing an NSDictionary of Sights. Set the flag and provide the delegate with this object
                self.completeDictionary = YES;
                [self.delegate sightsDatabaseFinishedLoading:self withData:self.sights];
                
            }
            else
            {
                NSLog(@"Sightsdatabase cannot be processed. Delegate has not implemented necessary method to support loading in memory");
            }
        }
        else
        {
            //Check if the required delegate method was implemented
            if ([self.delegate respondsToSelector:
                 @selector(loadedSightRecord:withData:)])
            {
            
#warning For future implementation: The sight object would have to be adapted to hold a new Category object, that would help the delegate method manage Sights within Categories. 
                
            }
            else
            {
                 NSLog(@"Sightsdatabase cannot be processed. Delegate has not implemented necessary method to support loading on record-by-record basis");
            }
   
        }
        
    }
    
}

#pragma mark - Internet helpers

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
//Delegate method to run when the app has first made an internet connection
{
    //initialize the JSON property
    self.json = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
//Delegate method to run when the app is receiving data
{
    //Add data to the JSON property
    [self.json appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
//Delegate method to run when all data was received
{
        [self parseJson:self.json];

}


@end
