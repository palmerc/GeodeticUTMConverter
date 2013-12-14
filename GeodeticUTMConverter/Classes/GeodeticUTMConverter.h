//
//  GeodeticUTMConverter.h
//  GeodeticUTMConverter
//
//  Created by Cameron Lowell Palmer & Mariia Ruchko on 19.06.12.
//  Copyright (c) 2012 Cameron Lowell Palmer & Mariia Ruchko. All rights reserved.
//
//  Code converted from Javascript as written by Chuck Taylor http://home.hiwaay.net/~taylorc/toolbox/geography/geoutm.html
//  Reference: Hoffmann-Wellenhof, B., Lichtenegger, H., and Collins, J., GPS: Theory and Practice, 3rd ed.  New York: Springer-Verlag Wien, 1994.
//

#import <MapKit/MapKit.h>



typedef double UTMDouble;
typedef unsigned int UTMGridZone;

typedef enum {
    kUTMHemisphereNorthern,
    kUTMHemisphereSouthern
} UTMHemisphere;

typedef struct {
    UTMDouble northing;
    UTMDouble easting;
    UTMGridZone gridZone;
    UTMHemisphere hemisphere;
} UTMCoordinates;

typedef struct {
    UTMDouble equitorialRadius;
    UTMDouble polarRadius;
} UTMDatum;



@interface GeodeticUTMConverter : NSObject

@property (nonatomic, assign) UTMDatum utmDatum;

+ (CLLocationCoordinate2D)UTMCoordinatesToLatitudeAndLongitude:(UTMCoordinates)UTMCoordinates;
+ (UTMCoordinates)latitudeAndLongitudeToUTMCoordinates:(CLLocationCoordinate2D)latitudeAndLongitudeCoordinates;

- (id)initWithDatum:(UTMDatum)datum;

- (CLLocationCoordinate2D)UTMCoordinatesToLatitudeAndLongitude:(UTMCoordinates)UTMCoordinates;
- (UTMCoordinates)latitudeAndLongitudeToUTMCoordinates:(CLLocationCoordinate2D)latitudeAndLongitudeCoordinates;
@end



#ifndef CLPGeodeticUTMConverter_UTMDatumMake
#define CLPGeodeticUTMConverter_UTMDatumMake

static inline UTMCoordinates UTMCoordinatesMake(UTMDouble northing, UTMDouble easting, UTMGridZone gridZone, UTMHemisphere hemisphere)
{
    UTMCoordinates UTMCoordinates;
    UTMCoordinates.northing = northing;
    UTMCoordinates.easting = easting;
    UTMCoordinates.gridZone = gridZone;
    UTMCoordinates.hemisphere = hemisphere;
    
    return UTMCoordinates;
}

static inline UTMDatum UTMDatumMake(UTMDouble equitorialRadius, UTMDouble polarRadius)
{
    UTMDatum UTMDatum;
    UTMDatum.equitorialRadius = equitorialRadius;
    UTMDatum.polarRadius = polarRadius;
    
    return UTMDatum;
}

#endif
