//
//  SightsDatabase.h
//  CityGuide-ObjC-NoNib
//
//  Created by Roger Carvalho on 16/07/2015.
//  Copyright (c) 2015 RDC Media Ltd. All rights reserved.
//
/*
 The SightsDatabase Class handles a complete database of Sights. It gets this database from a JSON file. It can either load up the entire JSON to memory and then provide this as an NSDictionary for other objects to use, or it can provide the sights one by one via delegation. In the latter case, the other object should handle the individual records how they see fit.
 
You should initiate a sightsDatabase using the designated initializer:

 - (id)initWithDelegate:(id)delegate;

When initializing a sightsDatabase, any caller needs to provide itself as delegate and should abide by the SightsDatabaseDelegate protocol and implement:
 
 -(BOOL)sightsShouldLoadInMemory:(SightsDatabase *)database;

This tells the sightsDatabase whether or not to load up all sights in memory or whether to provide them one by one. In the case of full load into memory, the delegate should implement:
 
 -(void)sightsDatabaseFinishedLoading:(SightsDatabase *)database withData:(NSDictionary *)data;

This will be called when the full database is loaded and ready to use. 
 
If the database should provide sights one by one (in case of massive databases that would cause the app to crash when loaded into memory), the delegate should implement:
 
 -(void)loadedSightRecord:(SightsDatabase *)database withData:(Sight *)data;

This will be called for every single record, and would allow a caller to load the data into a SQLite database, core data, a file, or any other method of storage.
 
Other objects can force the sightsDatabase to refresh its data. It can either refresh its data from the package or from a remote server.

 */

#import <Foundation/Foundation.h>
#import "Sight.h"
#import "Constants.h"


//Let the compiler know how to process the protocol definition.
@class SightsDatabase;

//Declare the protocol any delegate of this object needs to implement
@protocol SightsDatabaseDelegate <NSObject>

@required
-(BOOL)sightsShouldLoadInMemory:(SightsDatabase *)database;
//Return 'YES' to receive an NSDictionary, return 'NO' to receive records one by one.
@optional
-(void)sightsDatabaseFinishedLoading:(SightsDatabase *)database withData:(NSDictionary *)data;
//Required for 'YES'
-(void)loadedSightRecord:(SightsDatabase *)database withData:(Sight *)data;
//Required for 'NO'
@end

@interface SightsDatabase : NSObject<NSURLConnectionDataDelegate>

//The only applicable public property for the class is its delegate
@property() id<SightsDatabaseDelegate> delegate;

//Designated initializer
- (id)initWithDelegate:(id)delegate;

//Public methods
-(void)downloadData;
//Downloads data from a remote server
-(void)importLocalData;
//Imports data from the package. The JSON file should be called "sights.json"
-(BOOL)isCompleteDatabase;
//Can be called at any time to check whether the database is currently processing data or ready for use

//NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
@end
