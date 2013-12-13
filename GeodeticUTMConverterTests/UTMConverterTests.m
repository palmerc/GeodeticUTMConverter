//
//  UTMConverterTests.m
//  UTMConverterTests
//
//  Created by Cameron Lowell Palmer & Mariia Ruchko on 19.06.12.
//  Copyright (c) 2012 Cameron Lowell Palmer & Mariia Ruchko. All rights reserved.
//

#import "UTMConverterTests.h"

#import "GeodeticUTMConverter.h"



@implementation UTMConverterTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testUTMToLatLong {
    UTMCoordinates coordinates;
    coordinates.easting = 598430;
    coordinates.northing = 6643010;
    coordinates.gridZone = 32;
    coordinates.hemisphere = kUTMHemisphereNorthern;
    
    GeodeticUTMConverter *utmConverter = [[GeodeticUTMConverter alloc] init];
    CLLocationCoordinate2D latLong = [utmConverter UTMCoordinatesToLatitudeAndLongitude:coordinates];
    [utmConverter release];
    
    NSLog(@"Latitude: %f, Longitude: %f", latLong.latitude, latLong.longitude);
    STAssertTrue(latLong.latitude == 59.912814611065265, @"Should be equal.");
    STAssertTrue(latLong.longitude == 10.760192985178369, @"Should be equal.");
}

- (void)testLatLongToUTM {
    CLLocationCoordinate2D coordingates;
    coordingates.latitude = 59.912814611065265;
    coordingates.longitude = 10.760192985178369;

    GeodeticUTMConverter *utmConverter = [[GeodeticUTMConverter alloc] init];
    UTMCoordinates utmCoordinates = [utmConverter latitudeAndLongitudeToUTMCoordinates:coordingates];
    [utmConverter release];

    NSString *hemisphere;
    if (utmCoordinates.hemisphere == kUTMHemisphereNorthern) {
        hemisphere = @"Northern";
    } else {
        hemisphere = @"Southern";
    }
    
    NSLog(@"Northing: %f, Easting: %f, GridZone: %d, Hemisphere: %@", utmCoordinates.northing, utmCoordinates.easting, utmCoordinates.gridZone, hemisphere);
    STAssertTrue((int)utmCoordinates.northing == 6643010, @"Should be equal.");
    STAssertTrue((int)utmCoordinates.easting == 598430, @"Should be equal.");
    STAssertTrue(utmCoordinates.gridZone == 32, @"");
    STAssertTrue(utmCoordinates.hemisphere == kUTMHemisphereNorthern, @"");
}

@end
