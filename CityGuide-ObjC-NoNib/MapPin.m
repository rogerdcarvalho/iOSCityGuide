//
//  MapPin.m
//  CityGuide-ObjC-NoNib
//
//  Created by Roger Carvalho on 16/07/2015.
//  Copyright (c) 2015 RDC Media Ltd. All rights reserved.
//

#import "MapPin.h"

@implementation MapPin

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize placeId;
@synthesize categoryId;


- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:placeName description:description placeId:(NSInteger)placeIda categoryId:(NSString*)categoryIda;
{
    self = [super init];
    if (self != nil) {
        coordinate = location;
        title = placeName;
        subtitle = description;
        placeId=placeIda;
        categoryId=categoryIda;
        
    }
    return self;
}

@end