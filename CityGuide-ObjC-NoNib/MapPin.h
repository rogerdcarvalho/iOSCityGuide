//
//  MapPin.h
//  CityGuide-ObjC-NoNib
//
//  Created by Roger Carvalho on 16/07/2015.
//  Copyright (c) 2015 RDC Media Ltd. All rights reserved.
//
/*

 Custom MKAnnotation to support the MapViewController. It allows pins to hold ID reference data
 
*/
#import "MapPin.h"
#import <MapKit/MapKit.h>

@interface MapPin : NSObject<MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
    NSInteger placeId;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic,readonly,copy) NSString *title;
@property (nonatomic,readonly,copy) NSString *subtitle;
@property (nonatomic) NSInteger placeId;
@property (nonatomic) NSString *categoryId;


- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:(NSString *)placeName description:(NSString *)description placeId:(NSInteger)placeId categoryId:(NSString*)categoryId;

@end
